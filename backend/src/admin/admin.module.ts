import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';
import { User } from '../users/entities/user.entity';
import { ServiceRequest } from '../jobs/entities/service-request.entity';
import { Technician } from '../technicians/entities/technician.entity';
import { Payment } from '../payments/entities/payment.entity';
import { ServicesModule } from '../services/services.module';

@Module({
    imports: [
        TypeOrmModule.forFeature([User, ServiceRequest, Technician, Payment]),
        ServicesModule,
    ],
    controllers: [AdminController],
    providers: [AdminService],
})
export class AdminModule { }
