import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { User } from '../users/entities/user.entity';
import { Technician, TechnicianStatus } from '../technicians/entities/technician.entity';
import { ServiceCategory } from '../services/entities/service-category.entity';
import { ServiceRequest, ServiceRequestStatus } from '../jobs/entities/service-request.entity';
import { Payment, PaymentStatus } from '../payments/entities/payment.entity';

@Injectable()
export class AdminService {
    constructor(
        @InjectRepository(User)
        private userRepository: Repository<User>,
        @InjectRepository(Technician)
        private technicianRepository: Repository<Technician>,
        @InjectRepository(ServiceCategory)
        private serviceCategoryRepository: Repository<ServiceCategory>,
        @InjectRepository(ServiceRequest)
        private serviceRequestRepository: Repository<ServiceRequest>,
        @InjectRepository(Payment)
        private paymentRepository: Repository<Payment>,
    ) { }

    // Technician Management
    async getPendingTechnicians(): Promise<Technician[]> {
        return this.technicianRepository.find({
            where: { status: TechnicianStatus.PENDING },
            relations: ['user'],
            order: { createdAt: 'DESC' },
        });
    }

    async getAllTechnicians(status?: TechnicianStatus): Promise<Technician[]> {
        const where = status ? { status } : {};
        return this.technicianRepository.find({
            where,
            relations: ['user'],
            order: { createdAt: 'DESC' },
        });
    }

    async approveTechnician(technicianId: string): Promise<Technician> {
        await this.technicianRepository.update(technicianId, {
            status: TechnicianStatus.APPROVED,
        });
        return this.technicianRepository.findOne({
            where: { id: technicianId },
            relations: ['user'],
        });
    }

    async rejectTechnician(technicianId: string): Promise<Technician> {
        await this.technicianRepository.update(technicianId, {
            status: TechnicianStatus.REJECTED,
        });
        return this.technicianRepository.findOne({
            where: { id: technicianId },
            relations: ['user'],
        });
    }

    async toggleTechnicianStatus(
        technicianId: string,
        isActive: boolean,
    ): Promise<void> {
        const technician = await this.technicianRepository.findOne({
            where: { id: technicianId },
            relations: ['user'],
        });
        await this.userRepository.update(technician.userId, { isActive });
    }

    // Service Category Management
    async getAllServiceCategories(): Promise<ServiceCategory[]> {
        return this.serviceCategoryRepository.find({
            order: { name: 'ASC' },
        });
    }

    async createServiceCategory(
        data: Partial<ServiceCategory>,
    ): Promise<ServiceCategory> {
        const category = this.serviceCategoryRepository.create(data);
        return this.serviceCategoryRepository.save(category);
    }

    async updateServiceCategory(
        id: string,
        data: Partial<ServiceCategory>,
    ): Promise<ServiceCategory> {
        await this.serviceCategoryRepository.update(id, data);
        return this.serviceCategoryRepository.findOne({ where: { id } });
    }

    async deleteServiceCategory(id: string): Promise<void> {
        await this.serviceCategoryRepository.update(id, { isActive: false });
    }

    // Job Monitoring
    async getAllServiceRequests(filters?: {
        status?: ServiceRequestStatus;
        technicianId?: string;
    }): Promise<ServiceRequest[]> {
        const where: any = {};
        if (filters?.status) where.status = filters.status;
        if (filters?.technicianId) where.technicianId = filters.technicianId;

        return this.serviceRequestRepository.find({
            where,
            relations: ['customer', 'technician', 'serviceCategory'],
            order: { createdAt: 'DESC' },
        });
    }

    async reassignJob(
        serviceRequestId: string,
        newTechnicianId: string,
    ): Promise<ServiceRequest> {
        await this.serviceRequestRepository.update(serviceRequestId, {
            technicianId: newTechnicianId,
            status: ServiceRequestStatus.TECHNICIAN_ASSIGNED,
            assignedAt: new Date(),
        });
        return this.serviceRequestRepository.findOne({
            where: { id: serviceRequestId },
            relations: ['customer', 'technician', 'serviceCategory'],
        });
    }

    // Payments & Analytics
    async getAllPayments(): Promise<Payment[]> {
        return this.paymentRepository.find({
            relations: ['serviceRequest'],
            order: { createdAt: 'DESC' },
        });
    }

    async getAnalytics(startDate?: Date, endDate?: Date): Promise<any> {
        const dateFilter = startDate && endDate ? Between(startDate, endDate) : {};

        const totalJobs = await this.serviceRequestRepository.count({
            where: { createdAt: dateFilter },
        });

        const completedJobs = await this.serviceRequestRepository.count({
            where: {
                status: ServiceRequestStatus.COMPLETED,
                createdAt: dateFilter,
            },
        });

        const totalRevenue = await this.paymentRepository
            .createQueryBuilder('payment')
            .select('SUM(payment.amount)', 'total')
            .where('payment.status = :status', { status: PaymentStatus.COMPLETED })
            .andWhere(
                startDate && endDate
                    ? 'payment.createdAt BETWEEN :startDate AND :endDate'
                    : '1=1',
                { startDate, endDate },
            )
            .getRawOne();

        const totalCommission = await this.paymentRepository
            .createQueryBuilder('payment')
            .select('SUM(payment.commissionAmount)', 'total')
            .where('payment.status = :status', { status: PaymentStatus.COMPLETED })
            .andWhere(
                startDate && endDate
                    ? 'payment.createdAt BETWEEN :startDate AND :endDate'
                    : '1=1',
                { startDate, endDate },
            )
            .getRawOne();

        const activeTechnicians = await this.technicianRepository.count({
            where: { isOnline: true, status: TechnicianStatus.APPROVED },
        });

        const topCategories = await this.serviceRequestRepository
            .createQueryBuilder('sr')
            .select('sc.name', 'category')
            .addSelect('COUNT(sr.id)', 'count')
            .innerJoin('sr.serviceCategory', 'sc')
            .where(
                startDate && endDate
                    ? 'sr.createdAt BETWEEN :startDate AND :endDate'
                    : '1=1',
                { startDate, endDate },
            )
            .groupBy('sc.id')
            .orderBy('count', 'DESC')
            .limit(5)
            .getRawMany();

        return {
            totalJobs,
            completedJobs,
            revenue: parseFloat(totalRevenue?.total || 0),
            commission: parseFloat(totalCommission?.total || 0),
            activeTechnicians,
            topCategories,
        };
    }
}
