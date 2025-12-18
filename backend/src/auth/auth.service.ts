import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { OtpService } from './otp.service';
import { User, UserRole } from '../users/entities/user.entity';

export interface JwtPayload {
    sub: string;
    phone: string;
    role: UserRole;
}

@Injectable()
export class AuthService {
    constructor(
        @InjectRepository(User)
        private userRepository: Repository<User>,
        private jwtService: JwtService,
        private otpService: OtpService,
    ) { }

    async requestOtp(phone: string): Promise<{ message: string }> {
        await this.otpService.generateOtp(phone);
        return { message: 'OTP sent successfully' };
    }

    async verifyOtp(
        phone: string,
        code: string,
        role?: UserRole,
    ): Promise<{ accessToken: string; user: User }> {
        const isValid = await this.otpService.verifyOtp(phone, code);

        if (!isValid) {
            throw new UnauthorizedException('Invalid or expired OTP');
        }

        // Find or create user
        let user = await this.userRepository.findOne({ where: { phone } });

        if (!user) {
            user = this.userRepository.create({
                phone,
                role: role || UserRole.CUSTOMER,
            });
            await this.userRepository.save(user);
        }

        // Generate JWT token
        const payload: JwtPayload = {
            sub: user.id,
            phone: user.phone,
            role: user.role,
        };

        const accessToken = this.jwtService.sign(payload);

        return { accessToken, user };
    }

    async validateUser(payload: JwtPayload): Promise<User> {
        const user = await this.userRepository.findOne({
            where: { id: payload.sub },
        });

        if (!user || !user.isActive) {
            throw new UnauthorizedException('User not found or inactive');
        }

        return user;
    }

    async updateFcmToken(userId: string, fcmToken: string): Promise<void> {
        await this.userRepository.update(userId, { fcmToken });
    }
}
