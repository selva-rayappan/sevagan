import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import Razorpay from 'razorpay';
import * as crypto from 'crypto';
import { Payment, PaymentMethod, PaymentStatus } from './entities/payment.entity';
import { JobsService } from '../jobs/jobs.service';
import { TechniciansService } from '../technicians/technicians.service';
import { NotificationsService } from '../notifications/notifications.service';
import { ServiceRequestStatus } from '../jobs/entities/service-request.entity';

@Injectable()
export class PaymentsService {
    private razorpay: Razorpay;

    constructor(
        @InjectRepository(Payment)
        private paymentRepository: Repository<Payment>,
        private jobsService: JobsService,
        private techniciansService: TechniciansService,
        private notificationsService: NotificationsService,
        private configService: ConfigService,
    ) {
        this.razorpay = new Razorpay({
            key_id: this.configService.get('RAZORPAY_KEY_ID'),
            key_secret: this.configService.get('RAZORPAY_KEY_SECRET'),
        });
    }

    async createPayment(
        serviceRequestId: string,
        method: PaymentMethod,
    ): Promise<Payment> {
        const serviceRequest = await this.jobsService.findById(serviceRequestId);

        if (serviceRequest.status !== ServiceRequestStatus.JOB_COMPLETED) {
            throw new BadRequestException('Job must be completed before payment');
        }

        const amount = serviceRequest.finalPrice;
        const category = serviceRequest.serviceCategory;
        const commissionPercent = category.commissionPercent;

        const commissionAmount = (amount * commissionPercent) / 100;
        const platformFee = 0; // Can be configured separately
        const technicianAmount = amount - commissionAmount - platformFee;

        const payment = this.paymentRepository.create({
            serviceRequestId,
            amount,
            platformFee,
            commissionAmount,
            technicianAmount,
            method,
            status: PaymentStatus.PENDING,
        });

        const saved = await this.paymentRepository.save(payment);

        // Create Razorpay order for UPI payments
        if (method === PaymentMethod.UPI) {
            const order = await this.razorpay.orders.create({
                amount: amount * 100, // Razorpay expects amount in paise
                currency: 'INR',
                receipt: `order_${saved.id}`,
            });

            saved.razorpayOrderId = order.id;
            await this.paymentRepository.save(saved);
        }

        return saved;
    }

    async verifyPayment(
        paymentId: string,
        razorpayPaymentId: string,
        razorpaySignature: string,
    ): Promise<Payment> {
        const payment = await this.paymentRepository.findOne({
            where: { id: paymentId },
            relations: ['serviceRequest'],
        });

        if (!payment) {
            throw new BadRequestException('Payment not found');
        }

        // Verify Razorpay signature
        const text = `${payment.razorpayOrderId}|${razorpayPaymentId}`;
        const expectedSignature = crypto
            .createHmac('sha256', this.configService.get('RAZORPAY_KEY_SECRET'))
            .update(text)
            .digest('hex');

        if (expectedSignature !== razorpaySignature) {
            throw new BadRequestException('Invalid payment signature');
        }

        // Update payment status
        payment.razorpayPaymentId = razorpayPaymentId;
        payment.razorpaySignature = razorpaySignature;
        payment.status = PaymentStatus.COMPLETED;

        await this.paymentRepository.save(payment);

        // Update service request status
        await this.jobsService.markAsPaid(payment.serviceRequestId);

        // Update technician wallet
        await this.techniciansService.updateWalletBalance(
            payment.serviceRequest.technicianId,
            payment.technicianAmount,
        );

        // Send notification
        await this.notificationsService.sendPaymentReceived(
            payment.serviceRequest.technicianId,
            payment.technicianAmount,
        );

        return payment;
    }

    async confirmCashPayment(
        serviceRequestId: string,
        technicianId: string,
    ): Promise<Payment> {
        const payment = await this.paymentRepository.findOne({
            where: { serviceRequestId },
            relations: ['serviceRequest'],
        });

        if (!payment) {
            throw new BadRequestException('Payment not found');
        }

        if (payment.serviceRequest.technicianId !== technicianId) {
            throw new BadRequestException('Unauthorized');
        }

        payment.status = PaymentStatus.COMPLETED;
        await this.paymentRepository.save(payment);

        // Update technician wallet
        await this.techniciansService.updateWalletBalance(
            technicianId,
            payment.technicianAmount,
        );

        return payment;
    }

    async findByServiceRequestId(serviceRequestId: string): Promise<Payment> {
        return this.paymentRepository.findOne({
            where: { serviceRequestId },
        });
    }
}
