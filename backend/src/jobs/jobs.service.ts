import {
    Injectable,
    NotFoundException,
    BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { ServiceRequest, ServiceRequestStatus } from './entities/service-request.entity';
import { Rating } from './entities/rating.entity';
import { JobMatchingService } from './job-matching.service';
import { ServicesService } from '../services/services.service';
import { TechniciansService } from '../technicians/technicians.service';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class JobsService {
    constructor(
        @InjectRepository(ServiceRequest)
        private serviceRequestRepository: Repository<ServiceRequest>,
        @InjectRepository(Rating)
        private ratingRepository: Repository<Rating>,
        private jobMatchingService: JobMatchingService,
        private servicesService: ServicesService,
        private techniciansService: TechniciansService,
        private notificationsService: NotificationsService,
    ) { }

    async createServiceRequest(
        customerId: string,
        data: Partial<ServiceRequest>,
    ): Promise<ServiceRequest> {
        // Get service category to calculate estimated price
        const category = await this.servicesService.findById(data.serviceCategoryId);

        const serviceRequest = this.serviceRequestRepository.create({
            ...data,
            customerId,
            estimatedPrice: category.basePrice,
            status: ServiceRequestStatus.REQUESTED,
        });

        const saved = await this.serviceRequestRepository.save(serviceRequest);

        // Find and notify nearby technicians
        await this.jobMatchingService.findAndNotifyTechnicians(
            saved.id,
            saved.locationLat,
            saved.locationLng,
            [category.name],
        );

        return saved;
    }

    async findById(id: string): Promise<ServiceRequest> {
        const request = await this.serviceRequestRepository.findOne({
            where: { id },
            relations: ['customer', 'technician', 'serviceCategory'],
        });

        if (!request) {
            throw new NotFoundException('Service request not found');
        }

        return request;
    }

    async findByCustomerId(customerId: string): Promise<ServiceRequest[]> {
        return this.serviceRequestRepository.find({
            where: { customerId },
            relations: ['technician', 'serviceCategory'],
            order: { createdAt: 'DESC' },
        });
    }

    async findByTechnicianId(technicianId: string): Promise<ServiceRequest[]> {
        return this.serviceRequestRepository.find({
            where: { technicianId },
            relations: ['customer', 'serviceCategory'],
            order: { createdAt: 'DESC' },
        });
    }

    async acceptJob(
        serviceRequestId: string,
        technicianId: string,
    ): Promise<ServiceRequest> {
        // Try to accept job using Redis lock
        const accepted = await this.jobMatchingService.acceptJob(
            serviceRequestId,
            technicianId,
        );

        if (!accepted) {
            throw new BadRequestException('Job already assigned to another technician');
        }

        // Generate Start Job OTP
        const startJobOtp = Math.floor(1000 + Math.random() * 9000).toString();

        // Update service request
        await this.serviceRequestRepository.update(serviceRequestId, {
            technicianId,
            status: ServiceRequestStatus.TECHNICIAN_ASSIGNED,
            assignedAt: new Date(),
            startJobOtp,
        });

        const request = await this.findById(serviceRequestId);

        // Notify customer
        await this.notificationsService.sendTechnicianAssigned(
            request.customerId,
            serviceRequestId,
            technicianId,
        );

        return request;
    }

    async startJob(
        serviceRequestId: string,
        technicianId: string,
        otp: string,
    ): Promise<ServiceRequest> {
        const request = await this.findById(serviceRequestId);

        if (request.technicianId !== technicianId) {
            throw new BadRequestException('Unauthorized');
        }

        if (request.status !== ServiceRequestStatus.TECHNICIAN_ASSIGNED) {
            throw new BadRequestException('Job cannot be started in current status');
        }

        if (request.startJobOtp !== otp) {
            throw new BadRequestException('Invalid OTP');
        }

        await this.serviceRequestRepository.update(serviceRequestId, {
            status: ServiceRequestStatus.JOB_STARTED,
            startedAt: new Date(),
        });

        // Notify customer
        await this.notificationsService.sendJobStarted(
            request.customerId,
            serviceRequestId,
        );

        return this.findById(serviceRequestId);
    }

    async completeJob(
        serviceRequestId: string,
        technicianId: string,
        finalPrice: number,
    ): Promise<ServiceRequest> {
        const request = await this.findById(serviceRequestId);

        if (request.technicianId !== technicianId) {
            throw new BadRequestException('Unauthorized');
        }

        await this.serviceRequestRepository.update(serviceRequestId, {
            status: ServiceRequestStatus.JOB_COMPLETED,
            completedAt: new Date(),
            finalPrice,
        });

        // Increment technician's completed jobs count
        await this.techniciansService.incrementCompletedJobs(technicianId);

        // Notify customer
        await this.notificationsService.sendJobCompleted(
            request.customerId,
            serviceRequestId,
        );

        return this.findById(serviceRequestId);
    }

    async cancelJob(
        serviceRequestId: string,
        userId: string,
        reason: string,
    ): Promise<ServiceRequest> {
        const request = await this.findById(serviceRequestId);

        if (request.customerId !== userId && request.technician?.userId !== userId) {
            throw new BadRequestException('Unauthorized');
        }

        await this.serviceRequestRepository.update(serviceRequestId, {
            status: ServiceRequestStatus.CANCELLED,
            cancelledAt: new Date(),
            cancellationReason: reason,
        });

        // Cancel job matching
        await this.jobMatchingService.cancelJobMatching(serviceRequestId);

        return this.findById(serviceRequestId);
    }

    async rateJob(
        serviceRequestId: string,
        customerId: string,
        rating: number,
        comment?: string,
    ): Promise<Rating> {
        const request = await this.findById(serviceRequestId);

        if (request.customerId !== customerId) {
            throw new BadRequestException('Unauthorized');
        }

        if (request.status !== ServiceRequestStatus.COMPLETED) {
            throw new BadRequestException('Can only rate completed jobs');
        }

        // Check if already rated
        const existingRating = await this.ratingRepository.findOne({
            where: { serviceRequestId, customerId },
        });

        if (existingRating) {
            throw new BadRequestException('Job already rated');
        }

        const newRating = this.ratingRepository.create({
            serviceRequestId,
            customerId,
            technicianId: request.technicianId,
            rating,
            comment,
        });

        await this.ratingRepository.save(newRating);

        // Update technician's average rating
        await this.techniciansService.updateRating(request.technicianId, rating);

        return newRating;
    }
    async markAsPaid(serviceRequestId: string): Promise<ServiceRequest> {
        await this.serviceRequestRepository.update(serviceRequestId, {
            status: ServiceRequestStatus.COMPLETED,
        });

        return this.findById(serviceRequestId);
    }

    async findAvailableJobs(): Promise<ServiceRequest[]> {
        return this.serviceRequestRepository.find({
            where: {
                status: ServiceRequestStatus.REQUESTED,
                technicianId: null, // Note: This requires .IsNull() logic if strict, but null works in simple find
            },
            relations: ['customer', 'serviceCategory'],
            order: { createdAt: 'DESC' },
        });
    }
}
