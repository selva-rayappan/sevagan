import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';
import { User } from '../users/entities/user.entity';
import { Technician } from '../technicians/entities/technician.entity';
import { ServiceCategory } from '../services/entities/service-category.entity';
import { ServiceRequest } from '../jobs/entities/service-request.entity';
import { Payment } from '../payments/entities/payment.entity';
import { TechniciansModule } from '../technicians/technicians.module';
import { ServicesModule } from '../services/services.module';

@Module({
    imports: [
        TypeOrmModule.forFeature([
            User,
            Technician,
            ServiceCategory,
            ServiceRequest,
            Payment,
        ]),
        TechniciansModule,
        ServicesModule,
    ],
    controllers: [AdminController],
    providers: [AdminService],
})
export class AdminModule { }
