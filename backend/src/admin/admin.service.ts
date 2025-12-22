import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, UserRole } from '../users/entities/user.entity';
import { ServiceRequest, ServiceRequestStatus } from '../jobs/entities/service-request.entity';
import { Technician, TechnicianStatus } from '../technicians/entities/technician.entity';
import { Payment, PaymentStatus } from '../payments/entities/payment.entity';
import { ServicesService } from '../services/services.service';

@Injectable()
export class AdminService {
    constructor(
        @InjectRepository(User)
        private userRepository: Repository<User>,
        @InjectRepository(ServiceRequest)
        private serviceRequestRepository: Repository<ServiceRequest>,
        @InjectRepository(Technician)
        private technicianRepository: Repository<Technician>,
        @InjectRepository(Payment)
        private paymentRepository: Repository<Payment>,
        private servicesService: ServicesService,
    ) { }

    async getDashboardStats() {
        const totalUsers = await this.userRepository.count();
        const totalCustomers = await this.userRepository.count({ where: { role: UserRole.CUSTOMER } });
        const totalTechnicians = await this.technicianRepository.count();
        const pendingTechnicians = await this.technicianRepository.count({ where: { status: TechnicianStatus.PENDING } });

        const totalJobs = await this.serviceRequestRepository.count();
        const completedJobs = await this.serviceRequestRepository.count({ where: { status: ServiceRequestStatus.COMPLETED } });

        const totalRevenueResult = await this.paymentRepository
            .createQueryBuilder('payment')
            .select('SUM(payment.amount)', 'sum')
            .where('payment.status = :status', { status: PaymentStatus.COMPLETED })
            .getRawOne();

        const totalRevenue = totalRevenueResult ? parseFloat(totalRevenueResult.sum) || 0 : 0;

        return {
            users: {
                total: totalUsers,
                customers: totalCustomers,
                technicians: totalTechnicians,
                pendingTechnicians,
            },
            jobs: {
                total: totalJobs,
                completed: completedJobs,
            },
            revenue: {
                total: totalRevenue,
            },
        };
    }

    async approveTechnician(technicianId: string) {
        const technician = await this.technicianRepository.findOne({ where: { id: technicianId } });
        if (!technician) {
            throw new NotFoundException('Technician not found');
        }

        technician.status = TechnicianStatus.APPROVED;
        return this.technicianRepository.save(technician);
    }

    async rejectTechnician(technicianId: string) {
        const technician = await this.technicianRepository.findOne({ where: { id: technicianId } });
        if (!technician) {
            throw new NotFoundException('Technician not found');
        }

        technician.status = TechnicianStatus.REJECTED;
        return this.technicianRepository.save(technician);
    }

    async getAllTechnicians(status?: string) {
        const where = status ? { status: status as TechnicianStatus } : {};
        return this.technicianRepository.find({
            where,
            relations: ['user'],
            order: { createdAt: 'DESC' },
        });
    }

    async getPendingTechnicians() {
        return this.technicianRepository.find({
            where: { status: TechnicianStatus.PENDING },
            relations: ['user'],
        });
    }

    async getAnalytics() {
        // Reuse dashboard stats as base analytics
        const stats = await this.getDashboardStats();

        // Add more analytics data
        const activeJobs = await this.serviceRequestRepository.count({
            where: { status: ServiceRequestStatus.JOB_STARTED }
        });

        const onlineTechnicians = await this.technicianRepository.count({
            where: { isOnline: true, status: TechnicianStatus.APPROVED }
        });

        return {
            users: stats.users,
            jobs: {
                ...stats.jobs,
                active: activeJobs,
            },
            technicians: {
                total: stats.users.technicians,
                online: onlineTechnicians,
                pending: stats.users.pendingTechnicians,
            },
            revenue: stats.revenue.total,
        };
    }

    async getServiceCategories() {
        return this.servicesService.findAll();
    }

    async createServiceCategory(data: any) {
        // Delegate to existing service but wrap with admin permission check logic if needed
        // Since seeding is in service, maybe we should expose create in services service publicly?
        // Actually, better to keep modification logic restricted.
        // For MVP, likely just a direct db insert via ServicesService if exposed, or here.
        // Let's assume ServicesService doesn't have a public create method yet except seed.
        // We'll implement a create method in ServicesService and call it.
        return this.servicesService.create(data);
    }
}
