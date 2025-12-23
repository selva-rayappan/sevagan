# Testing Guide - New Features

## Prerequisites

### 1. Start the Backend Server

```bash
cd backend
npm run start:dev
```

**Expected Output:**
- Server should start on `http://localhost:3000`
- Database connection successful
- No errors in console

### 2. Verify Database Migration

The backend should automatically create the `customers` table on startup. Check your MySQL database:

```sql
SHOW TABLES;
-- Should see: customers, technicians, users, service_requests, etc.

DESCRIBE customers;
-- Should show: id, user_id, name, address, phone, created_at, updated_at
```

---

## Test 1: Backend - Customer Profile Endpoints

### Test Customer Profile Creation

```bash
# 1. First, login as a customer to get a token
curl -X POST http://localhost:3000/api/auth/otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "9876543210"}'

# 2. Verify OTP (use the OTP from console logs)
curl -X POST http://localhost:3000/api/auth/verify \
  -H "Content-Type: application/json" \
  -d '{"phone": "9876543210", "otp": "1234"}'

# Save the token from response

# 3. Create customer profile
curl -X POST http://localhost:3000/api/customers/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "name": "Test Customer",
    "address": "123 Test Street, Chennai"
  }'

# Expected: 201 Created with customer profile data

# 4. Get customer profile
curl -X GET http://localhost:3000/api/customers/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"

# Expected: 200 OK with profile data

# 5. Update customer profile
curl -X PUT http://localhost:3000/api/customers/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "name": "Updated Customer Name",
    "address": "456 New Address, Chennai"
  }'

# Expected: 200 OK with updated profile
```

---

## Test 2: Backend - Admin Technician CRUD

### Test Admin Create Technician

```bash
# 1. Login as admin
curl -X POST http://localhost:3000/api/auth/admin/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@sevagan.com",
    "password": "admin123"
  }'

# Save the admin token

# 2. Create a new technician (auto-approved)
curl -X POST http://localhost:3000/api/admin/technicians \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ADMIN_TOKEN_HERE" \
  -d '{
    "phone": "9988776655",
    "name": "Admin Created Technician",
    "skills": ["Electrician", "Plumber"],
    "experience": 5,
    "serviceRadiusKm": 10
  }'

# Expected: 201 Created with technician data, status should be "APPROVED"

# 3. Get all technicians
curl -X GET http://localhost:3000/api/admin/technicians \
  -H "Authorization: Bearer ADMIN_TOKEN_HERE"

# Expected: Array of technicians including the newly created one

# 4. Update technician
curl -X PUT http://localhost:3000/api/admin/technicians/TECHNICIAN_ID \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ADMIN_TOKEN_HERE" \
  -d '{
    "name": "Updated Technician Name",
    "experience": 7
  }'

# Expected: 200 OK with updated technician

# 5. Toggle technician status
curl -X PUT http://localhost:3000/api/admin/technicians/TECHNICIAN_ID/toggle-status \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ADMIN_TOKEN_HERE" \
  -d '{
    "isActive": false
  }'

# Expected: 200 OK, technician's user.isActive should be false

# 6. Delete technician
curl -X DELETE http://localhost:3000/api/admin/technicians/TECHNICIAN_ID \
  -H "Authorization: Bearer ADMIN_TOKEN_HERE"

# Expected: 200 OK with success message
```

---

## Test 3: Customer App - Profile Flow

### Prerequisites
- Customer app should be running
- Backend server should be running

### Test Steps

1. **Start Customer App**
   ```bash
   cd customer_app
   C:\Users\selvakumar.rayappan\flutter\bin\flutter.bat run
   ```

2. **Test Profile Creation Flow**
   - App should show login screen
   - Enter phone number: `9876543210`
   - Click "Send OTP"
   - Enter OTP from backend console
   - Click "Verify OTP"
   - **Expected**: App should navigate to `CustomerProfileCheckScreen`
   - **Expected**: Since no profile exists, should navigate to `CustomerProfileSetupScreen`
   - Fill in:
     - Name: "Test Customer"
     - Address: "123 Test Street, Chennai"
     - Phone: Should be auto-populated and disabled
   - Click "Continue"
   - **Expected**: Profile created, navigate to Home Screen

3. **Test Profile Already Exists**
   - Logout and login again with same phone number
   - **Expected**: Should skip profile setup and go directly to Home Screen

4. **Verify in Database**
   ```sql
   SELECT * FROM customers WHERE phone = '9876543210';
   -- Should show the created profile
   ```

---

## Test 4: Technician App - Landing Screen

### Prerequisites
- Technician app should be running

### Test Steps

1. **Start Technician App**
   ```bash
   cd technician_app
   C:\Users\selvakumar.rayappan\flutter\bin\flutter.bat run
   ```

2. **Test Landing Screen**
   - **Expected**: App should show `LandingScreen` (not login screen)
   - Verify UI elements:
     - ✅ Language toggle button (top right)
     - ✅ App logo/icon
     - ✅ Welcome text
     - ✅ "Register as Customer" button
     - ✅ "Register as Technician" button
     - ✅ "Login as Customer" button
     - ✅ "Login as Technician" button

3. **Test Language Toggle**
   - Click language toggle
   - Select "தமிழ்"
   - **Expected**: All text should change to Tamil
   - Select "English"
   - **Expected**: All text should change back to English

4. **Test Navigation**
   - Click "Login as Technician"
   - **Expected**: Navigate to LoginScreen
   - Go back to landing screen
   - Click "Register as Customer"
   - **Expected**: Navigate to LoginScreen

---

## Test 5: End-to-End Customer Flow

### Complete User Journey

1. **Customer Registration**
   - Open customer app
   - Login with new phone number
   - Complete profile setup
   - Verify home screen loads

2. **Create Service Request**
   - From home screen, select a service (e.g., "Electrician")
   - Fill in service request details
   - **Expected**: Address should be auto-populated from profile
   - Submit request
   - Verify request created

3. **Verify in Backend**
   ```bash
   curl -X GET http://localhost:3000/api/jobs/my-requests \
     -H "Authorization: Bearer CUSTOMER_TOKEN"
   ```
   - **Expected**: Should show the created service request with customer's address

---

## Common Issues & Troubleshooting

### Issue 1: "Customer profile not found" error
**Solution**: Make sure you're logged in as a CUSTOMER role, not TECHNICIAN

### Issue 2: Landing screen not showing
**Solution**: 
- Check if you updated `main.dart` correctly
- Try hot restart (not hot reload): `r` in terminal

### Issue 3: Localization errors
**Solution**: Run localization generation:
```bash
cd technician_app
C:\Users\selvakumar.rayappan\flutter\bin\flutter.bat gen-l10n
```

### Issue 4: Database table not created
**Solution**: 
- Check backend logs for migration errors
- Manually create table:
```sql
CREATE TABLE customers (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  name VARCHAR(255) NOT NULL,
  address TEXT NOT NULL,
  phone VARCHAR(20) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);
```

---

## Success Criteria

✅ **Backend**
- [ ] Customer profile endpoints working (GET, POST, PUT)
- [ ] Admin technician CRUD endpoints working
- [ ] Auto-approval for admin-created technicians

✅ **Customer App**
- [ ] Profile check screen works
- [ ] Profile setup screen works
- [ ] Profile data persists
- [ ] Navigation flow correct

✅ **Technician App**
- [ ] Landing screen displays
- [ ] Language toggle works
- [ ] Navigation to login works

---

## Next Steps After Testing

Once testing is complete:
1. Fix any bugs found
2. Implement admin panel UI for technician management
3. Add service request address auto-population
4. Deploy to staging environment
