import { Controller, Post, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { RequestOtpDto, VerifyOtpDto, UpdateFcmTokenDto } from './dto';
import { UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { GetUser } from '../common/decorators/get-user.decorator';
import { User } from '../users/entities/user.entity';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
    constructor(private authService: AuthService) { }

    @Post('otp')
    @HttpCode(HttpStatus.OK)
    @ApiOperation({ summary: 'Request OTP for phone number' })
    @ApiResponse({ status: 200, description: 'OTP sent successfully' })
    async requestOtp(@Body() dto: RequestOtpDto) {
        return this.authService.requestOtp(dto.phone);
    }

    @Post('verify')
    @HttpCode(HttpStatus.OK)
    @ApiOperation({ summary: 'Verify OTP and get access token' })
    @ApiResponse({ status: 200, description: 'OTP verified, token generated' })
    @ApiResponse({ status: 401, description: 'Invalid or expired OTP' })
    async verifyOtp(@Body() dto: VerifyOtpDto) {
        return this.authService.verifyOtp(dto.phone, dto.code, dto.role);
    }

    @Post('fcm-token')
    @UseGuards(JwtAuthGuard)
    @HttpCode(HttpStatus.OK)
    @ApiOperation({ summary: 'Update FCM token for push notifications' })
    async updateFcmToken(
        @GetUser() user: User,
        @Body() dto: UpdateFcmTokenDto,
    ) {
        await this.authService.updateFcmToken(user.id, dto.fcmToken);
        return { message: 'FCM token updated successfully' };
    }
}
