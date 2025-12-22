# Sevagan Quick Start - Test Phone Numbers & Registration

## 📱 Test Phone Numbers (Use These)

| Role | Phone Number | Purpose |
|------|--------------|---------|
| **Admin** | `9999999999` | Already exists in database (from seed) |
| **Customer 1** | `9876543210` | Test customer account |
| **Customer 2** | `9876543211` | Second customer (for multiple requests) |
| **Technician 1** | `9123456789` | Primary technician |
| **Technician 2** | `9123456790` | Second technician (for job matching) |
| **Any other** | `91XXXXXXXX` | Any 10-digit will work! |

## 🔑 How OTP Login Works

### There is NO separate registration form!

**Process**:
1. Open app (Customer or Technician)
2. Enter phone number (any 10 digits)
3. Click "Request OTP"
4. Check backend terminal for OTP:
   ```
   [OTP] Mock SMS: Your Sevagan OTP is 123456
   ```
5. Enter OTP in app
6. **If first time**: Account auto-created ✅
7. **If existing**: You're logged in ✅

## 🔧 Why Don't I See Any Technicians?

Technicians go through a 3-step process:

### Step 1: Auto-Registration (Login)
- Use phone `9123456789`
- Verify OTP → Account created
- User role: `TECHNICIAN`

### Step 2: Create Profile
After login, technician must:
- Enter name, skills, experience
- Upload Aadhaar photo
- Set service radius
- **Status**: `PENDING`

### Step 3: Admin Approval Required!
Technician won't appear until admin approves via:

**Option A: API**
```bash
# Get admin token first
curl -X POST http://localhost:3000/api/auth/otp -d '{"phone":"9999999999"}'
curl -X POST http://localhost:3000/api/auth/verify -d '{"phone":"9999999999","code":"<OTP>"}'

# Approve technician
curl -X POST http://localhost:3000/api/admin/technicians/<technician-id>/approve \
  -H "Authorization: Bearer <admin-token>"
```

**Option B: Database**
```sql
UPDATE technicians SET status = 'APPROVED' WHERE id = '<technician-id>';
```

**After approval**:
- Technician can toggle "Available/Online"
- Will receive job notifications
- Appears in job matching system

## 🚀 Quick Test (5 Minutes)

### 1. Create Customer Account
```
App: Customer app
Phone: 9876543210
OTP: <from backend logs>
→ Auto-registered as CUSTOMER
```

### 2. Create Technician Account  
```
App: Technician app
Phone: 9123456789
OTP: <from backend logs>
→ Auto-registered as TECHNICIAN
Fill profile → Status: PENDING
```

### 3. Approve Technician (via API)
```bash
# Use admin phone 9999999999
# Run approval API command above
→ Status: APPROVED
```

### 4. Technician Goes Online
```
App: Technician app
Toggle: "Available" = ON
→ Ready to receive jobs
```

### 5. Customer Creates Request
```
App: Customer app
Select: Electrician
Describe: "Fan not working"
Submit
→ Technician receives notification!
```

## 🐛 Common Issues

### "Invalid or expired OTP"
- Check backend terminal for actual code
- OTP expires in 5 minutes
- Make sure phone number matches exactly

### "No technicians found"
- Check technician is APPROVED (not PENDING)
- Check technician is ONLINE
- Check skills match (Electrician for electrician jobs)
- Check technician is within service radius

### "Can't find registration"
- There is NO registration screen!
- Login screen = Registration screen
- First OTP verification creates account

## 📍 Where OTPs Appear

**Backend Terminal** (where `npm run start:dev` is running):
```
[OTP] Sending OTP 123456 to 9876543210 via mock
[OTP] Mock SMS: Your Sevagan OTP is 123456
```

## 🎯 Account States

### Customer Account
- Created: ✅ On first OTP verification
- Active: ✅ Immediately
- Can create requests: ✅ Right away

### Technician Account
- Created: ✅ On first OTP verification  
- Profile filled: ⏳ Must complete
- Admin approved: ⏳ Required
- Can receive jobs: ✅ Only after approval + online

### Admin Account
- Exists: ✅ Pre-seeded (phone: 9999999999)
- Can approve: ✅ Immediately
