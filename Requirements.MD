# Sevagan App - Requirements Document

## 1. Objective

Build an on-demand hyperlocal services platform connecting customers with local technicians (electrician, plumber, AC, motor, washing machine, bike repair).

### MVP Scope

- Android-first
- Tamil + English
- Real-time job matching
- Cash + UPI payments
- Admin-controlled pricing & commissions

---

## 2. User Roles

### Roles

1. **Customer**
2. **Technician**
3. **Admin**

Each role has separate UI and permissions.

---

## 3. Functional Requirements (Role-Wise)

- Common landing screen for both Customer and Technician App 
  - with below features 
    - option to Toggle language (Tamil/ English)
    - Button for Customer and Technician
    - After OTP validation if Customer already exists navigate to Home screen
    - If Customer doesn't exist navigate to Profile Create screen
    - If Technician already exists navigate to Home screen
    - If Technician doesn't exist navigate to Profile Create screen

### 3.1 Customer App – Functional Spec

#### 3.1.1 Authentication

- Phone number login
- OTP verification
- Auto user creation on first login
- Profile Create screen with below details on first login
  - Name
  - Address
  - Phone (Auto populated)
- After Profile created navigate to Home screen

#### 3.1.2 Home Screen

- Service category grid:
  - Electrician
  - Plumber
  - Motor Repair
  - Washing Machine
  - AC Service
- Location auto-detect (GPS)
- Manual location override

#### 3.1.3 Raise Service Request

- Select service category
- Describe issue:
  - Text
  - Photo upload (max 3)
  - Optional voice note
- Show Address for this service request from profile (Auto Populate)
- Show estimated price range
- Confirm booking

#### 3.1.4 Job Matching

- Notify nearby technicians (within radius)
- Show technician details once accepted
- Live tracking (map view)

#### 3.1.5 Job Lifecycle

1. Requested
2. Technician assigned
3. Technician on the way
4. Job started
5. Job completed
6. Payment pending
7. Completed

#### 3.1.6 Payment

- Cash on service
- UPI (Razorpay/Cashfree)
- Show breakup:
  - Service charge
  - Platform fee

#### 3.1.7 Ratings & Review

- 1–5 star rating
- Optional comment

---

### 3.2 Technician App – Functional Spec

#### 3.2.1 Authentication & Onboarding

- Phone + OTP
- Profile details:
  - Name
  - Skills (multi-select)
  - Experience (years)
  - Service radius (km)
- Document upload:
  - Aadhaar (image)
- Status: Pending → Approved (Admin)

#### 3.2.2 Availability

- Online / Offline toggle

#### 3.2.3 Job Requests

- Push notification for new jobs
- Accept / Reject within time limit
- Auto-expire if no response

#### 3.2.4 Job Execution

- Navigate to customer (Maps)
- Start job
- Complete job
- Enter final service amount

#### 3.2.5 Earnings

- Wallet balance
- Completed jobs list
- Commission deducted
- Payout history

---

### 3.3 Admin Panel – Functional Spec

#### 3.3.1 Authentication

- Admin login (email + password)

#### 3.3.2 Technician Management

- Add / Delete / Edit technicians (Newly added Technicians are Auto approved)
- Approve / Reject technicians
- Enable / disable technicians
- View documents submitted by technicians

#### 3.3.3 Service Management

- Create service categories
- Set:
  - Base visit charge
  - Price range
  - Commission % or Amount (Editable Field)

#### 3.3.4 Job Monitoring

- View all service requests
- Filter by:
  - Status
  - City
  - Technician
- Manual Assignment of technician to Service Requests (Optional)
- Manual reassignment or override technician assigned to Service Requests (optional)

#### 3.3.5 Payments & Commission

- View all payments
- Commission calculation
- Payout reports

#### 3.3.6 Analytics Dashboard

- Daily jobs
- Revenue
- Active technicians
- Top service categories

---

## 4. Non-Functional Requirements

- Landing screen should have option to Toggle language (Tamil/ English)
- Tamil language support mandatory
- Low bandwidth optimized
- Works on low-end Android phones
- Secure APIs (JWT)
- GDPR-style data handling

---

## 5. System Architecture

### Frontend

- **Flutter** (Customer + Technician)
- **React** (Admin Panel)

### Backend

- **Node.js** (NestJS preferred) OR Spring Boot
- REST APIs
- JWT authentication

### Database

- **PostgreSQL** (preferred)
- **Redis** (job matching, caching)

### Infrastructure

- AWS / DigitalOcean
- Single VM or EC2 instance with Docker(MVP)
- S3 Object storage for images
- Redis for caching
- PostgreSQL for database
- JWT for authentication
- Nginx for reverse proxy

---

## 6. Database Schema (Detailed)

### USERS

```sql
users (
  id UUID PK,
  phone VARCHAR UNIQUE,
  role ENUM('CUSTOMER','TECHNICIAN','ADMIN'),
  created_at TIMESTAMP
)
```

### TECHNICIANS

```sql
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
```

### SERVICE_CATEGORIES

```sql
service_categories (
  id UUID PK,
  name,
  base_price,
  commission_percent
)
```

### SERVICE_REQUESTS

```sql
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
```

### PAYMENTS

```sql
payments (
  id UUID PK,
  service_request_id FK,
  amount,
  method ENUM('CASH','UPI'),
  status ENUM
)
```

---

## 7. API Specification (Key Endpoints)

### Auth

- `POST /auth/otp`
- `POST /auth/verify`

### Customer

- `POST /service-request`
- `GET /service-request/{id}`
- `POST /rating`

### Technician

- `GET /jobs/nearby`
- `POST /jobs/{id}/accept`
- `POST /jobs/{id}/start`
- `POST /jobs/{id}/complete`

### Admin

- `GET /admin/technicians`
- `POST /admin/technician/approve`
- `GET /admin/analytics`

---

## 8. Job Matching Logic

1. Find technicians:
   - Same service category
   - Within radius (default 5 km)
   - Online
2. Notify all eligible technicians
3. First accept wins
4. Lock job to technician

---

## 9. Payments Integration

### MVP

- Cash on service
- Razorpay UPI intent

### Flow

1. Technician enters final amount
2. Customer pays
3. Commission auto-calculated
4. Technician wallet updated

---

## 10. Maps & Location

- **Google Maps SDK** / MapMyIndia
- Features:
  - Current location
  - Technician tracking
  - Navigation link

---

## 11. Notifications

### Push Notifications

- Firebase Cloud Messaging (FCM)

### Events

- Job request
- Job accepted
- Technician arriving
- Job completed

---

## 12. UI/UX Guidelines

- Simple
- Large buttons
- Tamil-first labels
- Minimal steps
- Offline fallback messages

---

## 13. MVP Limitations (Intentional)

- ❌ No iOS initially
- ❌ No subscriptions
- ❌ No chat (call only)
- ❌ No AI pricing