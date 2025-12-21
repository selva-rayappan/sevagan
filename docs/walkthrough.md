# Sevagan MVP Walkthrough & Verification Guide

This document guides you through verifying the Sevagan hyperlocal services platform MVP.

## Prerequisities
1.  **Node.js**: Ensure Node.js (v18+) is installed.
2.  **PostgreSQL & Redis**: Ensure you have AWS RDS and ElastiCache endpoints configured in `backend/.env`.
    *   (Or local instances running if AWS is not ready).
3.  **Flutter**: Ensure Flutter SDK is installed and `flutter doctor` is healthy.
4.  **Emulators/Devices**: You need two devices/emulators to test the flow (one for Customer, one for Technician).

## 1. Backend Setup

### Install Dependencies
```bash
cd backend
npm install
```

### Database Migration
Run migrations to create tables:
```bash
npm run migration:run
```

### Seed Data
Seed initial service categories (Plumbing, Electrical, etc.) and users:
```bash
# Seeding happens automatically on module init for categories
# For users, you can use the signup flow or check the database
npm run start:dev
```
*Backend should be running at `http://localhost:3000`*

## 2. Mobile Apps Setup

### Customer App
```bash
cd customer_app
flutter create . # Re-generate platform folders if missing
flutter run
```

### Technician App
```bash
cd technician_app
flutter run
```

## 3. End-to-End Verification Flow

### Step 1: Account Creation
1.  **Technician App**: Sign up/Login with mobile `9999999999` (OTP: `123456`).
    - Note: This user is auto-created or you must create it.
    - Set status to **Online** by toggling the switch on Home Screen.
2.  **Customer App**: Sign up/Login with mobile `8888888888` (OTP: `123456`).

### Step 2: Create Service Request (Customer)
1.  Open **Customer App**.
2.  Select a category (e.g., **Plumbing**).
3.  Fill in description (e.g., "Leaky tap").
4.  Tap **"Book Now"**.
5.  You should be redirected to the **Job Status Screen** showing "Looking for Technician".

### Step 3: Accept Job (Technician)
1.  Open **Technician App**.
2.  Go to **"Requests"** tab (pull to refresh if needed).
3.  You should see the "Leaky tap" request.
4.  Tap **"Accept"**.
5.  Status changes to "Technician Assigned".
6.  Customer App should update to show Technician details and an **OTP** (e.g., `4521`).

### Step 4: Start Job (Technician)
1.  Technician arrives at location.
2.  Ask Customer for the **OTP**.
3.  Enter OTP in the **Job Tracking Screen** in Technician App.
4.  Tap **"Start Job"**.
5.  Job status updates to "Work in Progress" on both apps.

### Step 5: Complete Job (Technician)
1.  Technician finishes work.
2.  Enter **Final Price** (e.g., `500`) in Technician App.
3.  Tap **"Complete Job"**.
4.  Job status updates to "Job Completed" (Payment Pending).

### Step 6: Payment (Customer)
1.  Customer App shows **"PAY NOW"** button.
2.  Tap "PAY NOW".
3.  Razorpay Test Interface opens.
4.  Choose "Netbanking" -> "Success" (or use test card).
5.  Payment success!
6.  Job status updates to **"Job Closed & Paid"**.

## 4. Admin Features (API Only)
You can verify Admin APIs using Postman/Curl:
- **Stats**: `GET /api/admin/stats`
- **Approve Tech**: `POST /api/admin/technicians/:id/approve`

---
> [!IMPORTANT]
> **Troubleshooting**:
> - If apps don't connect to backend, check `api_config.dart` IP address (`10.0.2.2` for Android Emulator, `localhost` for iOS Sim).
> - If Redis fails, Job Matching will fall back or fail. Ensure Redis is reachable.
