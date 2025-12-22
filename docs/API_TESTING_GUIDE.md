# Sevagan Workflow Testing Guide

## Prerequisites
- Backend running on `http://localhost:3000`
- Postgres and Redis running via Docker
- Service categories seeded in database

## Quick Setup Variables
```bash
BASE_URL="http://localhost:3000/api"
```

---

## 🎯 Customer Workflow

### 1. Customer Registration & Login
```bash
# Step 1a: Request OTP
curl -X POST ${BASE_URL}/auth/otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "9876543210"}'

# Response: {"message": "OTP sent successfully"}
# Check backend logs for OTP code

# Step 1b: Verify OTP (use code from logs)
curl -X POST ${BASE_URL}/auth/verify   -H "Content-Type: application/json" \
  -d '{"phone": "9876543210", "code": "123456", "role": "CUSTOMER"}'

# Response: {..., "accessToken": "eyJhbGc..."}
# Save the accessToken for subsequent requests
CUSTOMER_TOKEN="<token from response>"
```

### 2. View Service Categories
```bash
curl -X GET ${BASE_URL}/services \
  -H "Authorization: Bearer ${CUSTOMER_TOKEN}"
  
# Response: Array of service categories (Electrician, Plumber, etc.)
```

### 3. Create Service Request
```bash
curl -X POST ${BASE_URL}/jobs \
  -H "Authorization: Bearer ${CUSTOMER_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "serviceCategoryId": "<category-id-from-step-2>",
    "description": "Fan not working, need urgent repair",
    "locationLat": 13.0827,
    "locationLng": 80.2707,
    "address": "123 Anna Nagar, Chennai"
  }'

# Response: Service request created with status "PENDING"
# Save the service request ID
SERVICE_REQUEST_ID="<id from response>"
```

### 4. Track Service Request
```bash
# View all requests
curl -X GET ${BASE_URL}/jobs/my-requests \
  -H "Authorization: Bearer ${CUSTOMER_TOKEN}"

# View specific request
curl -X GET ${BASE_URL}/jobs/${SERVICE_REQUEST_ID} \
  -H "Authorization: Bearer ${CUSTOMER_TOKEN}"
```

### 5. Rate Technician (After job completion)
```bash
curl -X POST ${BASE_URL}/jobs/${SERVICE_REQUEST_ID}/rate \
  -H "Authorization: Bearer ${CUSTOMER_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "rating": 5,
    "comment": "Excellent service, very professional"
  }'
```

---

## 🔧 Technician Workflow

### 1. Technician Registration
```bash
# Step 1a: Request OTP
curl -X POST ${BASE_URL}/auth/otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "9123456789"}'

# Step 1b: Verify OTP with TECHNICIAN role
curl -X POST ${BASE_URL}/auth/verify \
  -H "Content-Type: application/json" \
  -d '{"phone": "9123456789", "code": "<OTP>", "role": "TECHNICIAN"}'

# Save token
TECHNICIAN_TOKEN="<token from response>"
```

### 2. Create Technician Profile
```bash
curl -X POST ${BASE_URL}/technicians/profile \
  -H "Authorization: Bearer ${TECHNICIAN_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Ravi Kumar",
    "skills": ["electrician", "plumber"],
    "experience": 5,
    "serviceRadius": 10,
    "latitude": 13.0827,
    "longitude": 80.2707
  }'

# Response: Technician profile created with status "PENDING"
TECHNICIAN_ID="<id from response>"
```

### 3. Upload Aadhaar Document
```bash
curl -X POST ${BASE_URL}/technicians/upload-aadhaar \
  -H "Authorization: Bearer ${TECHNICIAN_TOKEN}" \
  -F "file=@/path/to/aadhaar.jpg"

# Response: {"url": "https://..."}
```

### 4. Admin Approval (Switch to Admin)
```bash
# Get admin token (using seed admin: admin@sevagan.com)
# Note: Admin login via email/password not implemented yet - use phone OTP with ADMIN role for now
# or manually create JWT token for testing

# Approve technician
curl -X POST ${BASE_URL}/admin/technicians/${TECHNICIAN_ID}/approve \
  -H "Authorization: Bearer ${ADMIN_TOKEN}"
```

### 5. Go Online
```bash
curl -X POST ${BASE_URL}/technicians/toggle-online \
  -H "Authorization: Bearer ${TECHNICIAN_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"isOnline": true}'

# Response: {"isOnline": true, ...}
```

### 6. View Available Jobs (Polling)
```bash
curl -X GET ${BASE_URL}/jobs/available \
  -H "Authorization: Bearer ${TECHNICIAN_TOKEN}"

# Response: Array of pending service requests matching technician's skills and location
```

### 7. Accept Job
```bash
curl -X POST ${BASE_URL}/jobs/${SERVICE_REQUEST_ID}/accept \
  -H "Authorization: Bearer ${TECHNICIAN_TOKEN}"

# Response: Job status changes to "ASSIGNED"
```

### 8. Start Job (with OTP)
```bash
# Customer receives OTP (check backend logs)
curl -X POST ${BASE_URL}/jobs/${SERVICE_REQUEST_ID}/start \
  -H "Authorization: Bearer ${TECHNICIAN_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"otp": "<OTP from customer>"}'

# Response: Job status changes to "IN_PROGRESS"
```

### 9. Complete Job
```bash
curl -X POST ${BASE_URL}/jobs/${SERVICE_REQUEST_ID}/complete \
  -H "Authorization: Bearer ${TECHNICIAN_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"finalPrice": 350}'

# Response: Job status changes to "COMPLETED"
```

### 10. View My Jobs
```bash
curl -X GET ${BASE_URL}/jobs/my-jobs \
  -H "Authorization: Bearer ${TECHNICIAN_TOKEN}"

# Response: Array of jobs assigned to this technician
```

---

## 🔄 Complete End-to-End Test Flow

1. **Customer creates request** → status: `PENDING`
2. **Backend notifies technicians** → (via push notification or polling)
3. **Technician accepts** → status: `ASSIGNED`
4. **Technician starts with OTP** → status: `IN_PROGRESS`
5. **Technician completes** → status: `COMPLETED`
6. **Customer pays** → status: `PAYMENT_COMPLETED`
7. **Customer rates** → Job fully complete

---

## 📋 Testing Checklist

### Customer Tests
- [ ] Register and login via OTP
- [ ] View service categories
- [ ] Create service request with location
- [ ] View list of my requests
- [ ] Track specific request status
- [ ] Rate completed job

### Technician Tests
- [ ] Register with TECHNICIAN role
- [ ] Create profile with skills
- [ ] Upload Aadhaar document
- [ ] Wait for admin approval
- [ ] Toggle online status
- [ ] Poll for available jobs
- [ ] Accept job
- [ ] Start job with OTP
- [ ] Complete job with final price
- [ ] View job history

### Admin Tests
- [ ] List pending technicians
- [ ] Approve/reject technician
- [ ] View all service requests
- [ ] Manage service categories

---

## 🐛 Common Issues

### "Invalid or expired OTP"
- Check backend logs for the actual OTP code
- Ensure OTP hasn't expired (5 minute default)
- Verify phone number matches exactly

### "Unauthorized" errors
- Ensure token is valid and not expired
- Check Authorization header format: `Bearer <token>`
- Verify role matches endpoint requirements

### No available jobs for technician
- Ensure technician is approved by admin
- Ensure technician is online
- Check skills match service category
- Verify location is within service radius

---

## 🔍 Backend Logs to Monitor
```bash
# Watch backend logs for:
- [OTP] Mock SMS: Your Sevagan OTP is XXXXXX
- [Notification] New job request for user...
- Database query logs for debugging
```
