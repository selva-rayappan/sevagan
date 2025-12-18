import {
    Controller,
    Get,
    Post,
    Body,
    Param,
    UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { PaymentsService } from './payments.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { GetUser } from '../common/decorators/get-user.decorator';
import { User, UserRole } from '../users/entities/user.entity';
import { PaymentMethod } from './entities/payment.entity';
import { TechniciansService } from '../technicians/technicians.service';

@ApiTags('payments')
@Controller('payments')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class PaymentsController {
    constructor(
        private paymentsService: PaymentsService,
        private techniciansService: TechniciansService,
    ) { }

    @Post('create')
    @Roles(UserRole.CUSTOMER)
    @ApiOperation({ summary: 'Create payment for service request' })
    async createPayment(
        @Body() data: { serviceRequestId: string; method: PaymentMethod },
    ) {
        return this.paymentsService.createPayment(data.serviceRequestId, data.method);
    }

    @Post('verify')
    @Roles(UserRole.CUSTOMER)
    @ApiOperation({ summary: 'Verify Razorpay payment' })
    async verifyPayment(
        @Body()
        data: {
            paymentId: string;
            razorpayPaymentId: string;
            razorpaySignature: string;
        },
    ) {
        return this.paymentsService.verifyPayment(
            data.paymentId,
            data.razorpayPaymentId,
            data.razorpaySignature,
        );
    }

    @Post('confirm-cash/:serviceRequestId')
    @Roles(UserRole.TECHNICIAN)
    @ApiOperation({ summary: 'Confirm cash payment received' })
    async confirmCashPayment(
        @Param('serviceRequestId') serviceRequestId: string,
        @GetUser() user: User,
    ) {
        const technician = await this.techniciansService.findByUserId(user.id);
        return this.paymentsService.confirmCashPayment(
            serviceRequestId,
            technician.id,
        );
    }

    @Get('service-request/:id')
    @ApiOperation({ summary: 'Get payment for service request' })
    async getPaymentByServiceRequest(@Param('id') id: string) {
        return this.paymentsService.findByServiceRequestId(id);
    }
}
