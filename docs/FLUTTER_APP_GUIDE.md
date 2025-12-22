# Sevagan Mobile Apps - Quick Start Guide

## ✅ Setup Complete
- ✅ Flutter dependencies installed
- ✅ `.env` files configured for localhost
- ✅ Backend running on `http://localhost:3000`

## 🚀 Running the Apps

### Customer App (Chrome)
```bash
cd c:\Users\selvakumar.rayappan\Documents\sevagan\sevagan\customer_app
C:\Users\selvakumar.rayappan\flutter\bin\flutter.bat run -d chrome
```

### Technician App (Chrome - separate window)
```bash
cd c:\Users\selvakumar.rayappan\Documents\sevagan\sevagan\technician_app
C:\Users\selvakumar.rayappan\flutter\bin\flutter.bat run -d chrome --web-port 8081
```
*Note: Using different port (8081) to run both apps simultaneously*

### Alternative: Edge Browser
Replace `-d chrome` with `-d edge`

## 🧪 Testing Workflows

### Quick Test Sequence
1. **Start Backend** (if not running):
   ```bash
   cd c:\Users\selvakumar.rayappan\Documents\sevagan\sevagan\backend
   cmd /c "npm run start:dev"
   ```

2. **Launch Customer App**
   - Check backend logs for OTP code
   - Login with phone: `9876543210`
   - Enter OTP from logs

3. **Launch Technician App** (separate terminal)
   - Login with phone: `9123456789`
   - Complete profile setup
   - Wait for admin approval (manual step via API)

## 🔧 Hot Reload
While the app is running:
- Press `r` in terminal to hot reload
- Press `R` to hot restart
- Press `q` to quit

## ⚠️ Known Limitations (Web Testing)
- **Maps**: Google Maps may not work (requires API key)
- **Camera**: Image upload limited on web
- **GPS**: Location services limited on web
- **Push Notifications**: Firebase may be disabled (placeholder credentials)

For full testing, consider setting up Android emulator later.

## 📱 Switching to Android Emulator (Future)
When emulator is set up, change `.env`:
```
API_BASE_URL=http://10.0.2.2:3000/api
```
Then run:
```bash
flutter run -d <emulator-device-id>
```
