# Quick Start - Testing New Features

## 🚀 Quick Commands
docker-compose up -d

### Start Backend
```bash
cd c:\Users\selvakumar.rayappan\Documents\sevagan\sevagan\backend
npm run start:dev
```
npm run migration:generate -- src/database/migrations/InitialSchema
npm run migration:run
### Start Customer App
```bash
cd c:\Users\selvakumar.rayappan\Documents\sevagan\sevagan\customer_app
C:\Users\selvakumar.rayappan\flutter\bin\flutter.bat run
```

### Start Technician App
```bash
cd c:\Users\selvakumar.rayappan\Documents\sevagan\sevagan\technician_app
C:\Users\selvakumar.rayappan\flutter\bin\flutter.bat run
```

---

## 🧪 Quick Test Scenarios

### Test 1: Customer Profile (5 min)
1. Start backend + customer app
2. Login with phone: `9876543210`
3. Fill profile: Name + Address
4. Verify home screen loads
5. ✅ **Success**: Profile created and saved

### Test 2: Landing Screen (2 min)
1. Start technician app
2. Verify landing screen shows (not login)
3. Toggle language Tamil ↔ English
4. Click buttons to test navigation
5. ✅ **Success**: All buttons work, language changes

### Test 3: Admin Create Technician (3 min)
Use Postman or curl:
```bash
POST http://localhost:3000/api/admin/technicians
Headers: Authorization: Bearer <ADMIN_TOKEN>
Body: {
  "phone": "9988776655",
  "name": "Test Tech",
  "skills": ["Electrician"],
  "experience": 5
}
```
✅ **Success**: Technician created with status="APPROVED"

---

## 📋 What to Test

### Priority 1 (Must Test)
- [ ] Customer profile creation
- [ ] Customer profile check on re-login
- [ ] Landing screen displays
- [ ] Language toggle works

### Priority 2 (Should Test)
- [ ] Admin create technician API
- [ ] Admin update technician API
- [ ] Profile data persists in database

### Priority 3 (Nice to Test)
- [ ] Admin delete technician
- [ ] Admin toggle technician status
- [ ] Error handling

---

## 🐛 Known Issues to Watch For

1. **Localization not updating**: Run `flutter gen-l10n` in technician_app
2. **Database table missing**: Check backend logs, may need manual table creation
3. **Hot reload not working**: Use hot restart (`r` in terminal)

---

## ✅ Success Indicators

**Backend Running:**
```
[Nest] INFO [NestFactory] Starting Nest application...
[Nest] INFO [InstanceLoader] AppModule dependencies initialized
```

**Customer Profile Created:**
```json
{
  "id": "uuid-here",
  "name": "Test Customer",
  "address": "123 Test Street",
  "phone": "9876543210"
}
```

**Landing Screen Loaded:**
- See "Welcome to Sevagan" text
- See 4 buttons (2 register, 2 login)
- Language toggle visible

---

## 📞 Quick Help

**Backend not starting?**
- Check if MySQL is running
- Check `.env` file exists
- Run `npm install` first

**Flutter app not building?**
- Run `flutter pub get`
- Check Flutter SDK path
- Try `flutter clean` then rebuild

**API calls failing?**
- Check backend is running on port 3000
- Verify token is valid
- Check CORS settings

---

See `TESTING_GUIDE.md` for detailed testing instructions.
