# Sevagan Database Schema

## Overview

The Sevagan platform uses PostgreSQL as the primary database with the following main entities:

- Users (customers, technicians, admins)
- Technicians (profile and service details)
- Service Categories
- Service Requests (jobs)
- Payments
- Ratings
- OTP Codes

## Entity Relationship Diagram

```
┌─────────────┐       ┌──────────────────┐       ┌────────────────────┐
│    Users    │──────<│   Technicians    │       │ Service Categories │
└─────────────┘       └──────────────────┘       └────────────────────┘
      │                        │                            │
      │                        │                            │
      │                        │                            │
      ▼                        ▼                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Service Requests                            │
└─────────────────────────────────────────────────────────────────┘
      │                        │
      │                        │
      ▼                        ▼
┌─────────────┐       ┌──────────────────┐
│  Payments   │       │     Ratings      │
└─────────────┘       └──────────────────┘
```

## Tables

### users

| Column      | Type      | Constraints           | Description                    |
|-------------|-----------|-----------------------|--------------------------------|
| id          | UUID      | PRIMARY KEY           | Unique user identifier         |
| phone       | VARCHAR   | UNIQUE, NOT NULL      | Phone number (with country code)|
| role        | ENUM      | NOT NULL              | CUSTOMER, TECHNICIAN, ADMIN    |
| name        | VARCHAR   | NULL                  | User's full name               |
| email       | VARCHAR   | NULL                  | Email address                  |
| isActive    | BOOLEAN   | DEFAULT true          | Account active status          |
| fcmToken    | VARCHAR   | NULL                  | Firebase Cloud Messaging token |
| createdAt   | TIMESTAMP | DEFAULT NOW()         | Account creation timestamp     |
| updatedAt   | TIMESTAMP | DEFAULT NOW()         | Last update timestamp          |

### technicians

| Column            | Type      | Constraints           | Description                    |
|-------------------|-----------|-----------------------|--------------------------------|
| id                | UUID      | PRIMARY KEY           | Unique technician identifier   |
| userId            | UUID      | FOREIGN KEY (users)   | Reference to user account      |
| name              | VARCHAR   | NOT NULL              | Technician's name              |
| skills            | TEXT[]    | NOT NULL              | Array of service skills        |
| experience        | INT       | NOT NULL              | Years of experience            |
| serviceRadiusKm   | FLOAT     | DEFAULT 5.0           | Service coverage radius        |
| status            | ENUM      | DEFAULT PENDING       | PENDING, APPROVED, REJECTED    |
| rating            | FLOAT     | DEFAULT 0             | Average rating (0-5)           |
| totalRatings      | INT       | DEFAULT 0             | Total number of ratings        |
| latitude          | FLOAT     | NULL                  | Current latitude               |
| longitude         | FLOAT     | NULL                  | Current longitude              |
| isOnline          | BOOLEAN   | DEFAULT false         | Online availability status     |
| aadhaarImageUrl   | VARCHAR   | NULL                  | Aadhaar document URL           |
| profileImageUrl   | VARCHAR   | NULL                  | Profile picture URL            |
| walletBalance     | FLOAT     | DEFAULT 0             | Current wallet balance         |
| completedJobs     | INT       | DEFAULT 0             | Total completed jobs           |
| createdAt         | TIMESTAMP | DEFAULT NOW()         | Registration timestamp         |
| updatedAt         | TIMESTAMP | DEFAULT NOW()         | Last update timestamp          |

### service_categories

| Column            | Type      | Constraints           | Description                    |
|-------------------|-----------|-----------------------|--------------------------------|
| id                | UUID      | PRIMARY KEY           | Unique category identifier     |
| name              | VARCHAR   | UNIQUE, NOT NULL      | Internal category name         |
| nameEn            | VARCHAR   | NOT NULL              | English display name           |
| nameTa            | VARCHAR   | NOT NULL              | Tamil display name             |
| description       | TEXT      | NULL                  | Category description           |
| basePrice         | FLOAT     | NOT NULL              | Base service price             |
| minPrice          | FLOAT     | NOT NULL              | Minimum price range            |
| maxPrice          | FLOAT     | NOT NULL              | Maximum price range            |
| commissionPercent | FLOAT     | DEFAULT 15.0          | Platform commission %          |
| iconUrl           | VARCHAR   | NULL                  | Category icon URL              |
| isActive          | BOOLEAN   | DEFAULT true          | Category active status         |
| createdAt         | TIMESTAMP | DEFAULT NOW()         | Creation timestamp             |
| updatedAt         | TIMESTAMP | DEFAULT NOW()         | Last update timestamp          |

### service_requests

| Column              | Type      | Constraints                  | Description                    |
|---------------------|-----------|------------------------------|--------------------------------|
| id                  | UUID      | PRIMARY KEY                  | Unique request identifier      |
| customerId          | UUID      | FOREIGN KEY (users)          | Customer who created request   |
| technicianId        | UUID      | FOREIGN KEY (technicians)    | Assigned technician            |
| serviceCategoryId   | UUID      | FOREIGN KEY (service_categories) | Service type              |
| status              | ENUM      | DEFAULT REQUESTED            | Job status (see flow below)    |
| description         | TEXT      | NOT NULL                     | Issue description              |
| imageUrls           | TEXT[]    | DEFAULT []                   | Uploaded image URLs            |
| voiceNoteUrl        | VARCHAR   | NULL                         | Voice note URL                 |
| estimatedPrice      | FLOAT     | NOT NULL                     | Initial price estimate         |
| finalPrice          | FLOAT     | NULL                         | Final charged amount           |
| locationLat         | FLOAT     | NOT NULL                     | Service location latitude      |
| locationLng         | FLOAT     | NOT NULL                     | Service location longitude     |
| locationAddress     | TEXT      | NULL                         | Human-readable address         |
| customerName        | VARCHAR   | NULL                         | Customer contact name          |
| customerPhone       | VARCHAR   | NULL                         | Customer contact phone         |
| assignedAt          | TIMESTAMP | NULL                         | Technician assignment time     |
| startedAt           | TIMESTAMP | NULL                         | Job start time                 |
| completedAt         | TIMESTAMP | NULL                         | Job completion time            |
| cancelledAt         | TIMESTAMP | NULL                         | Cancellation time              |
| cancellationReason  | TEXT      | NULL                         | Reason for cancellation        |
| createdAt           | TIMESTAMP | DEFAULT NOW()                | Request creation time          |
| updatedAt           | TIMESTAMP | DEFAULT NOW()                | Last update time               |

**Status Flow:**
```
REQUESTED → TECHNICIAN_ASSIGNED → TECHNICIAN_ON_THE_WAY → 
JOB_STARTED → JOB_COMPLETED → PAYMENT_PENDING → COMPLETED
```

### payments

| Column             | Type      | Constraints                  | Description                    |
|--------------------|-----------|------------------------------|--------------------------------|
| id                 | UUID      | PRIMARY KEY                  | Unique payment identifier      |
| serviceRequestId   | UUID      | FOREIGN KEY (service_requests)| Related service request       |
| amount             | FLOAT     | NOT NULL                     | Total payment amount           |
| platformFee        | FLOAT     | NOT NULL                     | Platform fee amount            |
| commissionAmount   | FLOAT     | NOT NULL                     | Commission deducted            |
| technicianAmount   | FLOAT     | NOT NULL                     | Amount credited to technician  |
| method             | ENUM      | NOT NULL                     | CASH, UPI                      |
| status             | ENUM      | DEFAULT PENDING              | PENDING, COMPLETED, FAILED     |
| razorpayOrderId    | VARCHAR   | NULL                         | Razorpay order ID              |
| razorpayPaymentId  | VARCHAR   | NULL                         | Razorpay payment ID            |
| razorpaySignature  | VARCHAR   | NULL                         | Payment verification signature |
| metadata           | TEXT      | NULL                         | Additional payment metadata    |
| createdAt          | TIMESTAMP | DEFAULT NOW()                | Payment creation time          |
| updatedAt          | TIMESTAMP | DEFAULT NOW()                | Last update time               |

### ratings

| Column           | Type      | Constraints                  | Description                    |
|------------------|-----------|------------------------------|--------------------------------|
| id               | UUID      | PRIMARY KEY                  | Unique rating identifier       |
| serviceRequestId | UUID      | FOREIGN KEY (service_requests)| Rated service request         |
| customerId       | UUID      | FOREIGN KEY (users)          | Customer who rated             |
| technicianId     | UUID      | FOREIGN KEY (technicians)    | Rated technician               |
| rating           | INT       | NOT NULL, CHECK (1-5)        | Star rating (1-5)              |
| comment          | TEXT      | NULL                         | Optional review comment        |
| createdAt        | TIMESTAMP | DEFAULT NOW()                | Rating submission time         |

### otp_codes

| Column     | Type      | Constraints           | Description                    |
|------------|-----------|-----------------------|--------------------------------|
| id         | UUID      | PRIMARY KEY           | Unique OTP identifier          |
| phone      | VARCHAR   | NOT NULL              | Phone number                   |
| code       | VARCHAR   | NOT NULL              | 6-digit OTP code               |
| expiresAt  | TIMESTAMP | NOT NULL              | OTP expiration time            |
| isUsed     | BOOLEAN   | DEFAULT false         | Whether OTP has been used      |
| createdAt  | TIMESTAMP | DEFAULT NOW()         | OTP generation time            |

## Indexes

```sql
-- Performance indexes
CREATE INDEX idx_technicians_location ON technicians(latitude, longitude);
CREATE INDEX idx_technicians_status ON technicians(status, isOnline);
CREATE INDEX idx_service_requests_status ON service_requests(status);
CREATE INDEX idx_service_requests_customer ON service_requests(customerId);
CREATE INDEX idx_service_requests_technician ON service_requests(technicianId);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_otp_codes_phone ON otp_codes(phone, expiresAt);
```

## Migrations

Migrations are managed using TypeORM. To create a new migration:

```bash
npm run migration:generate -- src/database/migrations/MigrationName
```

To run migrations:

```bash
npm run migration:run
```

To revert last migration:

```bash
npm run migration:revert
```
