import {
    Controller,
    Get,
    Post,
    Put,
    Delete,
    Body,
    Param,
    Query,
    UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AdminService } from './admin.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';
import { TechnicianStatus } from '../technicians/entities/technician.entity';
import { ServiceRequestStatus } from '../jobs/entities/service-request.entity';

@ApiTags('admin')
@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
@ApiBearerAuth()
export class AdminController {
    constructor(private adminService: AdminService) { }

    // Technician Management
    @Get('technicians/pending')
    @ApiOperation({ summary: 'Get pending technician approvals' })
    async getPendingTechnicians() {
        return this.adminService.getPendingTechnicians();
    }

    @Get('technicians')
    @ApiOperation({ summary: 'Get all technicians' })
    async getAllTechnicians(@Query('status') status?: TechnicianStatus) {
        return this.adminService.getAllTechnicians(status);
    }

    @Post('technicians/:id/approve')
    @ApiOperation({ summary: 'Approve technician' })
    async approveTechnician(@Param('id') id: string) {
        return this.adminService.approveTechnician(id);
    }

    @Post('technicians/:id/reject')
    @ApiOperation({ summary: 'Reject technician' })
    async rejectTechnician(@Param('id') id: string) {
        return this.adminService.rejectTechnician(id);
    }

    @Put('technicians/:id/toggle-status')
    @ApiOperation({ summary: 'Enable/disable technician' })
    async toggleTechnicianStatus(
        @Param('id') id: string,
        @Body() data: { isActive: boolean },
    ) {
        await this.adminService.toggleTechnicianStatus(id, data.isActive);
        return { message: 'Technician status updated' };
    }

    // Service Category Management
    @Get('services')
    @ApiOperation({ summary: 'Get all service categories' })
    async getAllServiceCategories() {
        return this.adminService.getAllServiceCategories();
    }

    @Post('services')
    @ApiOperation({ summary: 'Create service category' })
    async createServiceCategory(@Body() data: any) {
        return this.adminService.createServiceCategory(data);
    }

    @Put('services/:id')
    @ApiOperation({ summary: 'Update service category' })
    async updateServiceCategory(@Param('id') id: string, @Body() data: any) {
        return this.adminService.updateServiceCategory(id, data);
    }

    @Delete('services/:id')
    @ApiOperation({ summary: 'Delete service category' })
    async deleteServiceCategory(@Param('id') id: string) {
        await this.adminService.deleteServiceCategory(id);
        return { message: 'Service category deleted' };
    }

    // Job Monitoring
    @Get('jobs')
    @ApiOperation({ summary: 'Get all service requests' })
    async getAllServiceRequests(
        @Query('status') status?: ServiceRequestStatus,
        @Query('technicianId') technicianId?: string,
    ) {
        return this.adminService.getAllServiceRequests({ status, technicianId });
    }

    @Post('jobs/:id/reassign')
    @ApiOperation({ summary: 'Reassign job to different technician' })
    async reassignJob(
        @Param('id') id: string,
        @Body() data: { technicianId: string },
    ) {
        return this.adminService.reassignJob(id, data.technicianId);
    }

    // Payments
    @Get('payments')
    @ApiOperation({ summary: 'Get all payments' })
    async getAllPayments() {
        return this.adminService.getAllPayments();
    }

    // Analytics
    @Get('analytics')
    @ApiOperation({ summary: 'Get analytics dashboard data' })
    async getAnalytics(
        @Query('startDate') startDate?: string,
        @Query('endDate') endDate?: string,
    ) {
        const start = startDate ? new Date(startDate) : undefined;
        const end = endDate ? new Date(endDate) : undefined;
        return this.adminService.getAnalytics(start, end);
    }
}
