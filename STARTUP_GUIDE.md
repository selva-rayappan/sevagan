# Sevagan Application - Complete Startup Guide

## 📋 Prerequisites

Before starting, ensure you have the following installed:

- ✅ **Node.js** 18+ (for Backend and Admin Panel)
- ✅ **PostgreSQL** 14+ (Database)
- ✅ **Redis** 7+ (Caching)
- ✅ **Flutter** 3.16+ (for Mobile Apps)
- ✅ **Docker & Docker Compose** (optional, for easier setup)

---

## 🚀 Complete Startup Steps

### Option 1: Using Docker Compose (Recommended for Quick Start)
- Initiate Docker Desktop and start the services.
#### Step 1: Start Database Services
```bash
cd c:\Users\selvakumar.rayappan\Documents\sevagan\sevagan
docker-compose up -d
```

This will start:
- PostgreSQL on port 5432
- Redis on port 6379

---

### Option 2: Manual Setup (Without Docker)

If not using Docker, you need to manually start PostgreSQL and Redis services on your system.

---

## 1️⃣ Backend (NestJS API)

### Step 1: Navigate to Backend Directory
```bash
cd c:\Users\selvakumar.rayappan\Documents\sevagan\sevagan\backend
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Step 2: Install Dependencies (First Time Only)
```bash
npm install
```

### Step 3: Configure Environment Variables
Ensure `.env` file exists with proper configuration:
```env
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USER=postgres
DATABASE_PASSWORD=your_password
DATABASE_NAME=sevagan
REDIS_HOST=localhost
REDIS_PORT=6379
JWT_SECRET=your_jwt_secret
```

### Step 4: Run Database Migrations (First Time Only)
```bash
npm run migration:run
```

### Step 5: Start Backend Server
```bash
npm run start:dev
```

**✅ Success Indicator:**
```
[Nest] INFO [NestFactory] Starting Nest application...
[Nest] INFO [InstanceLoader] AppModule dependencies initialized
[Nest] INFO Application is running on: http://localhost:3000
```

**Backend will run on:** `http://localhost:3000`

---

## 2️⃣ Admin Panel (React/Vite)

### Step 1: Navigate to Admin Panel Directory
```bash
cd c:\Users\selvakumar.rayappan\Documents\sevagan\sevagan\admin-panel
```

### Step 2: Install Dependencies (First Time Only)
```bash
npm install
```

### Step 3: Configure Environment Variables
Ensure `.env` file exists:
```env
VITE_API_URL=http://localhost:3000/api
```

### Step 4: Start Admin Panel
```bash
npm run dev
```

**✅ Success Indicator:**
```
VITE v7.x.x ready in xxx ms

➜  Local:   http://localhost:5173/
➜  Network: use --host to expose
```

**Admin Panel will run on:** `http://localhost:5173`

**Default Admin Login:**
- Email: `admin@sevagan.com`
- Password: (check your backend seed data)

---

## 3️⃣ Customer App (Flutter)

### Step 1: Navigate to Customer App Directory
```bash
cd c:\Users\selvakumar.rayappan\Documents\sevagan\sevagan\customer_app
```

### Step 2: Install Dependencies (First Time Only)
```bash
C:\Users\selvakumar.rayappan\flutter\bin\flutter.bat pub get
```

### Step 3: Configure API Endpoint
Check `lib/config/api_config.dart`:
```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api';
}
```

### Step 4: Generate Localizations (First Time Only)
```bash
C:\Users\selvakumar.rayappan\flutter\bin\flutter.bat gen-l10n
```

### Step 5: Run Customer App
```bash
C:\Users\selvakumar.rayappan\flutter\bin\flutter.bat run
```

**✅ Success Indicator:**
- App launches on emulator/device
- Landing screen appears with language toggle
- Two buttons visible: "Customer" and "Technician"

**Test Phone Number:** `9876543210`

---

## 4️⃣ Technician App (Flutter)

### Step 1: Navigate to Technician App Directory
```bash
cd c:\Users\selvakumar.rayappan\Documents\sevagan\sevagan\technician_app
```

### Step 2: Install Dependencies (First Time Only)
```bash
C:\Users\selvakumar.rayappan\flutter\bin\flutter.bat pub get
```

### Step 3: Configure API Endpoint
Check `lib/config/api_config.dart`:
```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api';
}
```

### Step 4: Generate Localizations (First Time Only)
```bash
C:\Users\selvakumar.rayappan\flutter\bin\flutter.bat gen-l10n
```

### Step 5: Run Technician App
```bash
C:\Users\selvakumar.rayappan\flutter\bin\flutter.bat run
```

**✅ Success Indicator:**
- App launches on emulator/device
- Landing screen appears (same as customer app)
- Language toggle works
- Navigation to login works

**Test Phone Number:** `9988776655`

---

## 📊 Quick Reference - All Commands

### Start All Services (in separate terminals)

**Terminal 1 - Backend:**
```bash
cd c:\Users\selvakumar.rayappan\Documents\sevagan\sevagan\backend
npm run start:dev
```

**Terminal 2 - Admin Panel:**
```bash
cd c:\Users\selvakumar.rayappan\Documents\sevagan\sevagan\admin-panel
npm run dev
```

**Terminal 3 - Customer App:**
```bash
cd c:\Users\selvakumar.rayappan\Documents\sevagan\sevagan\customer_app
C:\Users\selvakumar.rayappan\flutter\bin\flutter.bat run
```

**Terminal 4 - Technician App:**
```bash
cd c:\Users\selvakumar.rayappan\Documents\sevagan\sevagan\technician_app
C:\Users\selvakumar.rayappan\flutter\bin\flutter.bat run
```

---

## 🔍 Verification Checklist

### Backend Running ✅
- [ ] Server starts without errors
- [ ] Port 3000 is accessible
- [ ] Database connection successful
- [ ] Redis connection successful

### Admin Panel Running ✅
- [ ] Vite dev server starts
- [ ] Accessible at http://localhost:5173
- [ ] Can see login page
- [ ] No console errors

### Customer App Running ✅
- [ ] App builds successfully
- [ ] Landing screen displays
- [ ] Language toggle works (Tamil ↔ English)
- [ ] "Customer" button navigates to login
- [ ] OTP can be requested

### Technician App Running ✅
- [ ] App builds successfully
- [ ] Landing screen displays
- [ ] Language toggle works
- [ ] "Technician" button navigates to login
- [ ] OTP can be requested

---

## 🐛 Troubleshooting

### ⚠️ PowerShell Execution Policy Error (Windows)

**Problem:** npm commands fail with error:
```
npm : File C:\Program Files\nodejs\npm.ps1 cannot be loaded because running 
scripts is disabled on this system.
PSSecurityException: UnauthorizedAccess
```

**Solution 1: Change Execution Policy (Recommended)**

Run PowerShell as Administrator and execute:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Solution 2: Use Command Prompt Instead**

Instead of PowerShell, use Command Prompt (cmd.exe) to run npm commands:
1. Press `Win + R`
2. Type `cmd` and press Enter
3. Navigate to your project directory
4. Run npm commands normally

**Solution 3: Bypass Policy for Single Command**

```powershell
powershell -ExecutionPolicy Bypass -Command "npm run start:dev"
```

**Solution 4: Use Node directly**

```bash
node node_modules/.bin/nest start --watch
```

> **Note:** After fixing the execution policy, close and reopen your terminal for changes to take effect.

---

### Backend Issues

**Problem:** Backend won't start
```bash
# Solution 1: Check if PostgreSQL is running
# Solution 2: Verify .env file exists and is configured
# Solution 3: Reinstall dependencies
npm install
```

**Problem:** Database connection failed
```bash
# Check PostgreSQL service is running
# Verify DATABASE_* variables in .env
# Run migrations
npm run migration:run
```

### Admin Panel Issues

**Problem:** Vite won't start
```bash
# Clear node_modules and reinstall
rm -rf node_modules
npm install
```

**Problem:** API calls fail
```bash
# Verify VITE_API_URL in .env points to http://localhost:3000/api
# Check backend is running
```

### Flutter App Issues

**Problem:** Build fails
```bash
# Clean and rebuild
C:\Users\selvakumar.rayappan\flutter\bin\flutter.bat clean
C:\Users\selvakumar.rayappan\flutter\bin\flutter.bat pub get
C:\Users\selvakumar.rayappan\flutter\bin\flutter.bat run
```

**Problem:** Localization errors
```bash
# Regenerate localizations
C:\Users\selvakumar.rayappan\flutter\bin\flutter.bat gen-l10n
```

**Problem:** API connection fails
```bash
# For Android emulator, use 10.0.2.2 instead of localhost
# Update lib/config/api_config.dart:
# static const String baseUrl = 'http://10.0.2.2:3000/api';
```

---

## 🎯 Testing the Complete Flow

### Test 1: Customer Registration & Profile Creation
1. Start Backend + Customer App
2. Click "Customer" button on landing screen
3. Enter phone: `9876543210`
4. Request OTP (check backend logs for OTP)
5. Verify OTP
6. Fill profile: Name + Address
7. Verify home screen loads

### Test 2: Technician Registration & Profile Creation
1. Start Backend + Technician App
2. Click "Technician" button on landing screen
3. Enter phone: `9988776655`
4. Request OTP
5. Verify OTP
6. Fill profile: Name, Skills, Experience
7. Wait for admin approval (or use admin panel)

### Test 3: Admin Panel Management
1. Start Backend + Admin Panel
2. Login with admin credentials
3. View dashboard analytics
4. Manage technicians (approve/reject/edit)
5. View service requests
6. Monitor payments

---

## 📱 Port Summary

| Component       | Port | URL                        |
|----------------|------|----------------------------|
| Backend API    | 3000 | http://localhost:3000      |
| Admin Panel    | 5173 | http://localhost:5173      |
| PostgreSQL     | 5432 | localhost:5432             |
| Redis          | 6379 | localhost:6379             |
| Customer App   | N/A  | Mobile Device/Emulator     |
| Technician App | N/A  | Mobile Device/Emulator     |

---

## 📞 Quick Help

**Need to stop services?**
- Backend/Admin: Press `Ctrl+C` in terminal
- Flutter Apps: Press `q` in terminal or stop from IDE
- Docker: `docker-compose down`

**Need to restart?**
- Backend: Just restart the `npm run start:dev` command
- Flutter: Press `R` for hot restart or `r` for hot reload

**Need fresh start?**
```bash
# Backend
cd backend
npm run migration:revert
npm run migration:run

# Flutter
flutter clean
flutter pub get
```

---

For detailed testing instructions, see `TESTING_GUIDE.md`
