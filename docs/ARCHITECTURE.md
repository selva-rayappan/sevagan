# Sevagan Platform Architecture

## System Overview

Sevagan is a hyperlocal services platform built with a microservices-inspired architecture, consisting of:

1. **Backend API** (NestJS + PostgreSQL + Redis)
2. **Customer Mobile App** (Flutter)
3. **Technician Mobile App** (Flutter)
4. **Admin Web Panel** (React + Vite)

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Client Layer                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Customer   │  │  Technician  │  │    Admin     │      │
│  │  Mobile App  │  │  Mobile App  │  │  Web Panel   │      │
│  │  (Flutter)   │  │  (Flutter)   │  │   (React)    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ HTTPS/REST
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    API Gateway / Load Balancer               │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                     Backend Services                         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              NestJS Application                       │  │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐        │  │
│  │  │  Auth  │ │  Jobs  │ │Payment │ │ Admin  │        │  │
│  │  │ Module │ │ Module │ │ Module │ │ Module │        │  │
│  │  └────────┘ └────────┘ └────────┘ └────────┘        │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
            │                    │                    │
            ▼                    ▼                    ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│   PostgreSQL     │  │      Redis       │  │   AWS S3         │
│   (Database)     │  │  (Job Matching   │  │ (File Storage)   │
│                  │  │   & Caching)     │  │                  │
└──────────────────┘  └──────────────────┘  └──────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                  External Services                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Razorpay   │  │   Firebase   │  │  Google Maps │      │
│  │  (Payments)  │  │     (FCM)    │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## Technology Stack

### Backend
- **Framework**: NestJS (Node.js + TypeScript)
- **Database**: PostgreSQL 14+
- **Cache**: Redis 7+
- **ORM**: TypeORM
- **Authentication**: JWT + OTP
- **API Documentation**: Swagger/OpenAPI
- **File Storage**: AWS S3

### Mobile Apps (Flutter)
- **Framework**: Flutter 3.16+
- **State Management**: Provider
- **HTTP Client**: Dio
- **Maps**: Google Maps Flutter
- **Location**: Geolocator
- **Notifications**: Firebase Cloud Messaging
- **Payments**: Razorpay Flutter SDK
- **Localization**: flutter_localizations (English + Tamil)

### Admin Panel
- **Framework**: React 18
- **Build Tool**: Vite
- **Routing**: React Router v6
- **HTTP Client**: Axios
- **UI**: TailwindCSS
- **Charts**: Recharts
- **Icons**: Heroicons

### External Integrations
- **Payment Gateway**: Razorpay
- **Push Notifications**: Firebase Cloud Messaging (FCM)
- **Maps & Geocoding**: Google Maps API
- **SMS**: Configurable (Twilio/AWS SNS/MSG91)
- **File Storage**: AWS S3

## Core Features

### 1. Authentication & Authorization

- **OTP-based authentication** for customers and technicians
- **Email/password authentication** for admin
- **JWT tokens** for session management
- **Role-based access control** (CUSTOMER, TECHNICIAN, ADMIN)

### 2. Job Matching System

The job matching system uses Redis for real-time coordination:

```
1. Customer creates service request
2. Backend queries nearby technicians (within radius)
3. Notifications sent to all eligible technicians
4. First technician to accept wins (Redis lock mechanism)
5. Other technicians notified that job is no longer available
```

**Key Components:**
- Haversine formula for distance calculation
- Redis SET NX for race condition handling
- Configurable search radius and timeout

### 3. Payment Processing

- **Cash on Service**: Manual confirmation by technician
- **UPI Payments**: Razorpay integration
- **Commission Calculation**: Automatic deduction
- **Wallet System**: Technician earnings tracking

**Payment Flow:**
```
1. Job completed → Payment created
2. Customer pays (Cash/UPI)
3. Commission calculated
4. Technician wallet updated
5. Payment marked as completed
```

### 4. Real-time Notifications

Firebase Cloud Messaging (FCM) for:
- New job requests (to technicians)
- Technician assignment (to customers)
- Job status updates
- Payment confirmations

### 5. Location Services

- GPS-based location detection
- Manual location override
- Geocoding for address display
- Real-time technician tracking
- Navigation integration

## Data Flow

### Service Request Creation

```
Customer App → Backend API → Database
                    ↓
              Job Matching Service
                    ↓
              Redis (Store job)
                    ↓
           Notification Service
                    ↓
        FCM → Technician Apps
```

### Job Acceptance

```
Technician App → Backend API
                      ↓
                 Redis Lock
                      ↓
              Update Database
                      ↓
           Notification Service
                      ↓
          FCM → Customer App
```

## Security

### API Security
- JWT token authentication
- Role-based access control
- Request validation (class-validator)
- SQL injection prevention (TypeORM)
- XSS protection (sanitization)

### Data Security
- Encrypted passwords (bcrypt)
- Secure OTP generation
- HTTPS/TLS in production
- Environment variable management
- Razorpay signature verification

### Mobile App Security
- Secure storage (shared_preferences)
- API key protection
- Certificate pinning (recommended)

## Scalability

### Horizontal Scaling
- Stateless backend (JWT)
- Load balancer support
- Multiple backend instances
- Redis for shared state

### Database Scaling
- Read replicas for queries
- Connection pooling
- Indexed queries
- Pagination for large datasets

### Caching Strategy
- Redis for job matching
- API response caching
- Static asset CDN

## Monitoring & Logging

### Application Logs
- Structured logging (NestJS Logger)
- Error tracking
- Request/response logging
- Performance metrics

### Infrastructure Monitoring
- Database connection pool
- Redis memory usage
- API response times
- Error rates

## Deployment Architecture

### Development
- Docker Compose for local services
- Hot reload for backend
- Flutter hot restart

### Production (AWS)
```
CloudFront (CDN)
      ↓
Application Load Balancer
      ↓
EC2 Instances (Auto Scaling)
      ↓
RDS PostgreSQL (Multi-AZ)
ElastiCache Redis
S3 (File Storage)
```

## Future Enhancements

- [ ] Real-time chat between customer and technician
- [ ] AI-based dynamic pricing
- [ ] Subscription plans for customers
- [ ] iOS app support
- [ ] Advanced analytics dashboard
- [ ] Automated payout system
- [ ] Multi-language support (beyond Tamil/English)
- [ ] Video call support for remote assistance
