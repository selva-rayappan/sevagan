import {
    Controller,
    Get,
    Post,
    Put,
    Body,
    Param,
    UseGuards,
    UseInterceptors,
    UploadedFiles,
} from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JobsService } from './jobs.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { GetUser } from '../common/decorators/get-user.decorator';
import { User, UserRole } from '../users/entities/user.entity';
import { UploadService } from '../upload/upload.service';
import { TechniciansService } from '../technicians/technicians.service';

@ApiTags('jobs')
@Controller('jobs')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class JobsController {
    constructor(
        private jobsService: JobsService,
        private uploadService: UploadService,
        private techniciansService: TechniciansService,
    ) { }

    @Post()
    @Roles(UserRole.CUSTOMER)
    @UseInterceptors(FilesInterceptor('images', 3))
    @ApiOperation({ summary: 'Create service request' })
    async createServiceRequest(
        @GetUser() user: User,
        @Body() data: any,
        @UploadedFiles() images: Express.Multer.File[],
    ) {
        let imageUrls: string[] = [];
        if (images && images.length > 0) {
            imageUrls = await this.uploadService.uploadMultipleFiles(images, 'service-requests');
        }

        return this.jobsService.createServiceRequest(user.id, {
            ...data,
            imageUrls,
        });
    }

    @Get('my-requests')
    @Roles(UserRole.CUSTOMER)
    @ApiOperation({ summary: 'Get customer service requests' })
    async getMyRequests(@GetUser() user: User) {
        return this.jobsService.findByCustomerId(user.id);
    }

    @Get('my-jobs')
    @Roles(UserRole.TECHNICIAN)
    @ApiOperation({ summary: 'Get technician jobs' })
    async getMyJobs(@GetUser() user: User) {
        const technician = await this.techniciansService.findByUserId(user.id);
        return this.jobsService.findByTechnicianId(technician.id);
    }

    @Get(':id')
    @ApiOperation({ summary: 'Get service request details' })
    async getServiceRequest(@Param('id') id: string) {
        return this.jobsService.findById(id);
    }

    @Post(':id/accept')
    @Roles(UserRole.TECHNICIAN)
    @ApiOperation({ summary: 'Accept service request' })
    async acceptJob(@Param('id') id: string, @GetUser() user: User) {
        const technician = await this.techniciansService.findByUserId(user.id);
        return this.jobsService.acceptJob(id, technician.id);
    }

    @Post(':id/start')
    @Roles(UserRole.TECHNICIAN)
    @ApiOperation({ summary: 'Start job' })
    async startJob(@Param('id') id: string, @GetUser() user: User) {
        const technician = await this.techniciansService.findByUserId(user.id);
        return this.jobsService.startJob(id, technician.id);
    }

    @Post(':id/complete')
    @Roles(UserRole.TECHNICIAN)
    @ApiOperation({ summary: 'Complete job' })
    async completeJob(
        @Param('id') id: string,
        @GetUser() user: User,
        @Body() data: { finalPrice: number },
    ) {
        const technician = await this.techniciansService.findByUserId(user.id);
        return this.jobsService.completeJob(id, technician.id, data.finalPrice);
    }

    @Post(':id/cancel')
    @ApiOperation({ summary: 'Cancel service request' })
    async cancelJob(
        @Param('id') id: string,
        @GetUser() user: User,
        @Body() data: { reason: string },
    ) {
        return this.jobsService.cancelJob(id, user.id, data.reason);
    }

    @Post(':id/rate')
    @Roles(UserRole.CUSTOMER)
    @ApiOperation({ summary: 'Rate completed job' })
    async rateJob(
        @Param('id') id: string,
        @GetUser() user: User,
        @Body() data: { rating: number; comment?: string },
    ) {
        return this.jobsService.rateJob(id, user.id, data.rating, data.comment);
    }
}
