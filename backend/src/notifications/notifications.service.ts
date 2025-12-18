import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';

@Injectable()
export class NotificationsService {
    private firebaseApp: admin.app.App;

    constructor(private configService: ConfigService) {
        // Initialize Firebase Admin SDK
        const privateKey = this.configService
            .get('FIREBASE_PRIVATE_KEY', '')
            .replace(/\\n/g, '\n');

        if (privateKey && this.configService.get('FIREBASE_PROJECT_ID')) {
            this.firebaseApp = admin.initializeApp({
                credential: admin.credential.cert({
                    projectId: this.configService.get('FIREBASE_PROJECT_ID'),
                    privateKey,
                    clientEmail: this.configService.get('FIREBASE_CLIENT_EMAIL'),
                }),
            });
        } else {
            console.warn('Firebase credentials not configured. Push notifications disabled.');
        }
    }

    async sendNotification(
        fcmToken: string,
        title: string,
        body: string,
        data?: Record<string, string>,
    ): Promise<void> {
        if (!this.firebaseApp) {
            console.log(`[FCM Mock] ${title}: ${body}`);
            return;
        }

        try {
            await admin.messaging().send({
                token: fcmToken,
                notification: {
                    title,
                    body,
                },
                data: data || {},
                android: {
                    priority: 'high',
                },
            });
        } catch (error) {
            console.error('Failed to send FCM notification:', error);
        }
    }

    async sendJobRequest(
        userId: string,
        serviceRequestId: string,
    ): Promise<void> {
        // In production, fetch user's FCM token from database
        // For now, this is a placeholder
        console.log(`[Notification] New job request for user ${userId}: ${serviceRequestId}`);
    }

    async sendTechnicianAssigned(
        customerId: string,
        serviceRequestId: string,
        technicianId: string,
    ): Promise<void> {
        console.log(
            `[Notification] Technician ${technicianId} assigned to job ${serviceRequestId} for customer ${customerId}`,
        );
    }

    async sendJobStarted(
        customerId: string,
        serviceRequestId: string,
    ): Promise<void> {
        console.log(`[Notification] Job ${serviceRequestId} started for customer ${customerId}`);
    }

    async sendJobCompleted(
        customerId: string,
        serviceRequestId: string,
    ): Promise<void> {
        console.log(`[Notification] Job ${serviceRequestId} completed for customer ${customerId}`);
    }

    async sendJobUnavailable(
        technicianId: string,
        serviceRequestId: string,
    ): Promise<void> {
        console.log(
            `[Notification] Job ${serviceRequestId} no longer available for technician ${technicianId}`,
        );
    }

    async sendPaymentReceived(
        technicianId: string,
        amount: number,
    ): Promise<void> {
        console.log(`[Notification] Payment of ₹${amount} received for technician ${technicianId}`);
    }
}
