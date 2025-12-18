# Sevagan API Documentation

## Base URL

```
Production: https://api.sevagan.com/api
Development: http://localhost:3000/api
```

## Authentication

All authenticated endpoints require a Bearer token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

## Endpoints

### Authentication

#### Request OTP

```http
POST /auth/otp
Content-Type: application/json

{
  "phone": "+919876543210"
}
```

**Response:**
```json
{
  "message": "OTP sent successfully"
}
```

#### Verify OTP

```http
POST /auth/verify
Content-Type: application/json

{
  "phone": "+919876543210",
  "code": "123456",
  "role": "CUSTOMER" // Optional: CUSTOMER, TECHNICIAN, ADMIN
}
```

**Response:**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "phone": "+919876543210",
    "role": "CUSTOMER"
  }
}
```

### Services

#### Get Service Categories

```http
GET /services
Authorization: Bearer <token>
```

**Response:**
```json
[
  {
    "id": "uuid",
    "name": "electrician",
    "nameEn": "Electrician",
    "nameTa": "மின்சாரம்",
    "basePrice": 200,
    "minPrice": 150,
    "maxPrice": 500,
    "commissionPercent": 15
  }
]
```

### Jobs (Customer)

#### Create Service Request

```http
POST /jobs
Authorization: Bearer <token>
Content-Type: multipart/form-data

{
  "serviceCategoryId": "uuid",
  "description": "Need to fix electrical wiring",
  "locationLat": 13.0827,
  "locationLng": 80.2707,
  "locationAddress": "123 Main St, Chennai",
  "images": [File, File] // Max 3 images
}
```

**Response:**
```json
{
  "id": "uuid",
  "customerId": "uuid",
  "serviceCategoryId": "uuid",
  "status": "REQUESTED",
  "description": "Need to fix electrical wiring",
  "estimatedPrice": 200,
  "locationLat": 13.0827,
  "locationLng": 80.2707,
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

#### Get My Requests

```http
GET /jobs/my-requests
Authorization: Bearer <token>
```

#### Rate Job

```http
POST /jobs/:id/rate
Authorization: Bearer <token>
Content-Type: application/json

{
  "rating": 5,
  "comment": "Excellent service!"
}
```

### Jobs (Technician)

#### Get My Jobs

```http
GET /jobs/my-jobs
Authorization: Bearer <token>
```

#### Accept Job

```http
POST /jobs/:id/accept
Authorization: Bearer <token>
```

#### Start Job

```http
POST /jobs/:id/start
Authorization: Bearer <token>
```

#### Complete Job

```http
POST /jobs/:id/complete
Authorization: Bearer <token>
Content-Type: application/json

{
  "finalPrice": 250
}
```

### Payments

#### Create Payment

```http
POST /payments/create
Authorization: Bearer <token>
Content-Type: application/json

{
  "serviceRequestId": "uuid",
  "method": "UPI" // or "CASH"
}
```

**Response:**
```json
{
  "id": "uuid",
  "serviceRequestId": "uuid",
  "amount": 250,
  "commissionAmount": 37.5,
  "technicianAmount": 212.5,
  "method": "UPI",
  "status": "PENDING",
  "razorpayOrderId": "order_xxx"
}
```

#### Verify Payment

```http
POST /payments/verify
Authorization: Bearer <token>
Content-Type: application/json

{
  "paymentId": "uuid",
  "razorpayPaymentId": "pay_xxx",
  "razorpaySignature": "signature_xxx"
}
```

### Admin

#### Get Analytics

```http
GET /admin/analytics?startDate=2024-01-01&endDate=2024-01-31
Authorization: Bearer <admin-token>
```

**Response:**
```json
{
  "totalJobs": 150,
  "completedJobs": 120,
  "revenue": 45000,
  "commission": 6750,
  "activeTechnicians": 25,
  "topCategories": [
    { "category": "Electrician", "count": 45 },
    { "category": "Plumber", "count": 38 }
  ]
}
```

#### Approve Technician

```http
POST /admin/technicians/:id/approve
Authorization: Bearer <admin-token>
```

#### Get All Jobs

```http
GET /admin/jobs?status=REQUESTED&technicianId=uuid
Authorization: Bearer <admin-token>
```

## Status Codes

- `200 OK`: Success
- `201 Created`: Resource created
- `400 Bad Request`: Invalid request
- `401 Unauthorized`: Missing or invalid token
- `403 Forbidden`: Insufficient permissions
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error

## Job Status Flow

```
REQUESTED → TECHNICIAN_ASSIGNED → TECHNICIAN_ON_THE_WAY → 
JOB_STARTED → JOB_COMPLETED → PAYMENT_PENDING → COMPLETED
```

## Error Response Format

```json
{
  "statusCode": 400,
  "message": "Invalid request",
  "error": "Bad Request"
}
```

## Rate Limiting

- 100 requests per minute per IP
- 1000 requests per hour per user

## Webhooks

### Razorpay Payment Webhook

```http
POST /payments/webhook
X-Razorpay-Signature: <signature>

{
  "event": "payment.captured",
  "payload": {
    "payment": {
      "entity": {
        "id": "pay_xxx",
        "amount": 25000,
        "status": "captured"
      }
    }
  }
}
```

For interactive API documentation, visit `/api/docs` (Swagger UI) when running the backend.
