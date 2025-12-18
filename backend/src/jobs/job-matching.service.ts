import { Injectable, Inject } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { TechniciansService } from '../technicians/technicians.service';
import { NotificationsService } from '../notifications/notifications.service';
import { Technician } from '../technicians/entities/technician.entity';
import { RedisClientType } from 'redis';

@Injectable()
export class JobMatchingService {
    private readonly defaultRadiusKm: number;
    private readonly acceptanceTimeoutSeconds: number;

    constructor(
        @Inject('REDIS_CLIENT')
        private redisClient: RedisClientType,
        private techniciansService: TechniciansService,
        private notificationsService: NotificationsService,
        private configService: ConfigService,
    ) {
        this.defaultRadiusKm = this.configService.get('DEFAULT_SEARCH_RADIUS_KM', 5);
        this.acceptanceTimeoutSeconds = this.configService.get(
            'JOB_ACCEPTANCE_TIMEOUT_SECONDS',
            300,
        );
    }

    async findAndNotifyTechnicians(
        serviceRequestId: string,
        latitude: number,
        longitude: number,
        skills: string[],
    ): Promise<Technician[]> {
        // Find nearby technicians
        const technicians = await this.techniciansService.findNearbyTechnicians(
            latitude,
            longitude,
            this.defaultRadiusKm,
            skills,
        );

        if (technicians.length === 0) {
            return [];
        }

        // Store job request in Redis with expiration
        const jobKey = `job:${serviceRequestId}`;
        await this.redisClient.setEx(
            jobKey,
            this.acceptanceTimeoutSeconds,
            JSON.stringify({
                serviceRequestId,
                technicianIds: technicians.map((t) => t.id),
                status: 'pending',
            }),
        );

        // Send notifications to all eligible technicians
        const notificationPromises = technicians.map((technician) =>
            this.notificationsService.sendJobRequest(
                technician.userId,
                serviceRequestId,
            ),
        );

        await Promise.all(notificationPromises);

        return technicians;
    }

    async acceptJob(
        serviceRequestId: string,
        technicianId: string,
    ): Promise<boolean> {
        const jobKey = `job:${serviceRequestId}`;
        const lockKey = `job:lock:${serviceRequestId}`;

        // Try to acquire lock using Redis SET NX (set if not exists)
        const lockAcquired = await this.redisClient.set(lockKey, technicianId, {
            NX: true,
            EX: 10, // Lock expires in 10 seconds
        });

        if (!lockAcquired) {
            // Another technician already accepted
            return false;
        }

        try {
            // Check if job is still available
            const jobData = await this.redisClient.get(jobKey);
            if (!jobData) {
                return false; // Job expired or already assigned
            }

            const job = JSON.parse(jobData);
            if (job.status !== 'pending') {
                return false; // Job already assigned
            }

            // Mark job as assigned
            job.status = 'assigned';
            job.assignedTechnicianId = technicianId;
            await this.redisClient.setEx(
                jobKey,
                this.acceptanceTimeoutSeconds,
                JSON.stringify(job),
            );

            // Notify other technicians that job is no longer available
            const otherTechnicians = job.technicianIds.filter(
                (id: string) => id !== technicianId,
            );

            const notificationPromises = otherTechnicians.map((id: string) =>
                this.notificationsService.sendJobUnavailable(id, serviceRequestId),
            );

            await Promise.all(notificationPromises);

            return true;
        } finally {
            // Release lock
            await this.redisClient.del(lockKey);
        }
    }

    async cancelJobMatching(serviceRequestId: string): Promise<void> {
        const jobKey = `job:${serviceRequestId}`;
        await this.redisClient.del(jobKey);
    }
}
