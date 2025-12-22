import { Controller, Get, Post, Body, Param, UseGuards, Put } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AdminService } from './admin.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@ApiTags('admin')
@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
@ApiBearerAuth()
export class AdminController {
    constructor(private readonly adminService: AdminService) { }

    @Get('stats')
    @ApiOperation({ summary: 'Get dashboard statistics' })
    async getStats() {
        return this.adminService.getDashboardStats();
    }

    @Get('technicians')
    @ApiOperation({ summary: 'Get all technicians (with optional status filter)' })
    async getAllTechnicians(@Param('status') status?: string) {
        return this.adminService.getAllTechnicians(status);
    }

    @Get('technicians/pending')
    @ApiOperation({ summary: 'Get pending technician approvals' })
    async getPendingTechnicians() {
        return this.adminService.getPendingTechnicians();
    }

    @Post('technicians/:id/approve')
    @ApiOperation({ summary: 'Approve a technician' })
    async approveTechnician(@Param('id') id: string) {
        return this.adminService.approveTechnician(id);
    }

    @Post('technicians/:id/reject')
    @ApiOperation({ summary: 'Reject a technician' })
    async rejectTechnician(@Param('id') id: string) {
        return this.adminService.rejectTechnician(id);
    }

    @Get('services')
    @ApiOperation({ summary: 'Get all service categories' })
    async getServices() {
        return this.adminService.getServiceCategories();
    }

    @Get('analytics')
    @ApiOperation({ summary: 'Get platform analytics' })
    async getAnalytics() {
        return this.adminService.getAnalytics();
    }

    @Post('categories')
    @ApiOperation({ summary: 'Create a new service category' })
    async createCategory(@Body() data: any) {
        return this.adminService.createServiceCategory(data);
    }
}
