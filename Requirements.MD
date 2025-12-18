Sevagan App

Objective

Build an on-demand hyperlocal services platform connecting customers with local technicians (electrician, plumber, AC, motor, washing machine, bike repair).

MVP Scope

Android-first

Tamil + English

Real-time job matching

Cash + UPI payments

Admin-controlled pricing & commissions

2. USER ROLES
Roles

Customer

Technician

Admin

Each role has separate UI and permissions.

3. FUNCTIONAL REQUIREMENTS (ROLE-WISE)
3.1 CUSTOMER APP – FUNCTIONAL SPEC
Authentication

Phone number login

OTP verification

Auto user creation on first login

Home Screen

Service category grid

Electrician

Plumber

Motor Repair

Washing Machine

AC Service

Location auto-detect (GPS)

Manual location override

Raise Service Request

Select service category

Describe issue:

Text

Photo upload (max 3)

Optional voice note

Show estimated price range

Confirm booking

Job Matching

Notify nearby technicians (within radius)

Show technician details once accepted

Live tracking (map view)

Job Lifecycle

Requested

Technician assigned

Technician on the way

Job started

Job completed

Payment pending

Completed

Payment

Cash on service

UPI (Razorpay/Cashfree)

Show breakup:

Service charge

Platform fee

Ratings & Review

1–5 star rating

Optional comment

3.2 TECHNICIAN APP – FUNCTIONAL SPEC
Authentication & Onboarding

Phone + OTP

Profile details:

Name

Skills (multi-select)

Experience (years)

Service radius (km)

Document upload:

Aadhaar (image)

Status: Pending → Approved (Admin)

Availability

Online / Offline toggle

Job Requests

Push notification for new jobs

Accept / Reject within time limit

Auto-expire if no response

Job Execution

Navigate to customer (Maps)

Start job

Complete job

Enter final service amount

Earnings

Wallet balance

Completed jobs list

Commission deducted

Payout history

3.3 ADMIN PANEL – FUNCTIONAL SPEC
Authentication

Admin login (email + password)

Technician Management

Approve / Reject technicians

Enable / disable technicians

View documents

Service Management

Create service categories

Set:

Base visit charge

Price range

Commission %

Job Monitoring

View all service requests

Filter by:

Status

City

Technician

Manual reassignment (optional)

Payments & Commission

View all payments

Commission calculation

Payout reports

Analytics Dashboard

Daily jobs

Revenue

Active technicians

Top service categories

4. NON-FUNCTIONAL REQUIREMENTS

Tamil language support mandatory

Low bandwidth optimized

Works on low-end Android phones

Secure APIs (JWT)

GDPR-style data handling

5. SYSTEM ARCHITECTURE
Frontend

Flutter (Customer + Technician)

React (Admin Panel)

Backend

Node.js (NestJS preferred) OR Spring Boot

REST APIs

JWT authentication

Database

PostgreSQL (preferred)

Redis (job matching, caching)

Infrastructure

AWS / DigitalOcean

Single VM (MVP)

Object storage for images

6. DATABASE SCHEMA (DETAILED)
USERS
users (
  id UUID PK,
  phone VARCHAR UNIQUE,
  role ENUM('CUSTOMER','TECHNICIAN','ADMIN'),
  created_at TIMESTAMP
)

TECHNICIANS
technicians (
  id UUID PK,
  user_id FK,
  name,
  skills TEXT[],
  experience INT,
  status ENUM('PENDING','APPROVED','REJECTED'),
  rating FLOAT,
  latitude,
  longitude
)

SERVICE_CATEGORIES
service_categories (
  id UUID PK,
  name,
  base_price,
  commission_percent
)

SERVICE_REQUESTS
service_requests (
  id UUID PK,
  customer_id FK,
  technician_id FK,
  service_category_id FK,
  status ENUM,
  estimated_price,
  final_price,
  location_lat,
  location_lng,
  created_at
)

PAYMENTS
payments (
  id UUID PK,
  service_request_id FK,
  amount,
  method ENUM('CASH','UPI'),
  status ENUM
)

7. API SPECIFICATION (KEY ENDPOINTS)
Auth

POST /auth/otp

POST /auth/verify

Customer

POST /service-request

GET /service-request/{id}

POST /rating

Technician

GET /jobs/nearby

POST /jobs/{id}/accept

POST /jobs/{id}/start

POST /jobs/{id}/complete

Admin

GET /admin/technicians

POST /admin/technician/approve

GET /admin/analytics

8. JOB MATCHING LOGIC

Find technicians:

Same service category

Within radius (default 5 km)

Online

Notify all eligible technicians

First accept wins

Lock job to technician

9. PAYMENTS INTEGRATION
MVP

Cash on service

Razorpay UPI intent

Flow

Technician enters final amount

Customer pays

Commission auto-calculated

Technician wallet updated

10. MAPS & LOCATION

Google Maps SDK / MapMyIndia

Features:

Current location

Technician tracking

Navigation link

11. NOTIFICATIONS
Push Notifications

Firebase Cloud Messaging (FCM)

Events

Job request

Job accepted

Technician arriving

Job completed

12. UI/UX GUIDELINES

Simple

Large buttons

Tamil-first labels

Minimal steps

Offline fallback messages

13. MVP LIMITATIONS (INTENTIONAL)

❌ No iOS initially
❌ No subscriptions
❌ No chat (call only)
❌ No AI pricing