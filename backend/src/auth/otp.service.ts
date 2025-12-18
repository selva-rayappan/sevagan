import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThan } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { OtpCode } from './entities/otp-code.entity';

@Injectable()
export class OtpService {
    constructor(
        @InjectRepository(OtpCode)
        private otpRepository: Repository<OtpCode>,
        private configService: ConfigService,
    ) { }

    async generateOtp(phone: string): Promise<string> {
        // Clean up expired OTPs
        await this.otpRepository.delete({
            expiresAt: LessThan(new Date()),
        });

        // Generate 6-digit OTP
        const code = Math.floor(100000 + Math.random() * 900000).toString();

        const expirationMinutes = this.configService.get('OTP_EXPIRATION_MINUTES', 5);
        const expiresAt = new Date();
        expiresAt.setMinutes(expiresAt.getMinutes() + expirationMinutes);

        // Save OTP
        const otp = this.otpRepository.create({
            phone,
            code,
            expiresAt,
        });

        await this.otpRepository.save(otp);

        // Send OTP via SMS
        await this.sendOtp(phone, code);

        return code;
    }

    async verifyOtp(phone: string, code: string): Promise<boolean> {
        const otp = await this.otpRepository.findOne({
            where: {
                phone,
                code,
                isUsed: false,
            },
        });

        if (!otp) {
            return false;
        }

        if (otp.expiresAt < new Date()) {
            return false;
        }

        // Mark OTP as used
        otp.isUsed = true;
        await this.otpRepository.save(otp);

        return true;
    }

    private async sendOtp(phone: string, code: string): Promise<void> {
        const provider = this.configService.get('SMS_PROVIDER', 'mock');

        console.log(`[OTP] Sending OTP ${code} to ${phone} via ${provider}`);

        switch (provider) {
            case 'twilio':
                await this.sendViaTwilio(phone, code);
                break;
            case 'aws_sns':
                await this.sendViaAwsSns(phone, code);
                break;
            case 'msg91':
                await this.sendViaMsg91(phone, code);
                break;
            case 'mock':
            default:
                // Mock implementation for development
                console.log(`[OTP] Mock SMS: Your Sevagan OTP is ${code}`);
                break;
        }
    }

    private async sendViaTwilio(phone: string, code: string): Promise<void> {
        // Implement Twilio integration
        // const twilio = require('twilio');
        // const client = twilio(accountSid, authToken);
        // await client.messages.create({ ... });
        console.log(`[OTP] Twilio integration not implemented yet`);
    }

    private async sendViaAwsSns(phone: string, code: string): Promise<void> {
        // Implement AWS SNS integration
        console.log(`[OTP] AWS SNS integration not implemented yet`);
    }

    private async sendViaMsg91(phone: string, code: string): Promise<void> {
        // Implement MSG91 integration
        console.log(`[OTP] MSG91 integration not implemented yet`);
    }
}
