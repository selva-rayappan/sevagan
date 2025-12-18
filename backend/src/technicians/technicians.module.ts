import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Technician } from './entities/technician.entity';
import { TechniciansService } from './technicians.service';
import { TechniciansController } from './technicians.controller';
import { UploadModule } from '../upload/upload.module';

@Module({
    imports: [TypeOrmModule.forFeature([Technician]), UploadModule],
    controllers: [TechniciansController],
    providers: [TechniciansService],
    exports: [TechniciansService],
})
export class TechniciansModule { }
