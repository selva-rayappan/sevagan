# Admin Panel Login

## ✅ Email/Password Login (WORKING)

The admin login endpoint is now active at `/auth/admin/login`.

### Login Credentials

**Email**: `admin@sevagan.com`  
**Password**: `Admin@123`

### Steps to Login

1. **Start Admin Panel** (if not running):
   ```bash
   cd c:\Users\selvakumar.rayappan\Documents\sevagan\sevagan\admin-panel
   npm run dev
   ```

2. **Open in Browser**: http://localhost:5173

3. **Enter Credentials**:
   - Email: `admin@sevagan.com`
   - Password: `Admin@123`

4. **Click Sign In** ✅

You're now logged into the admin panel!

## What You Can Do

Once logged in, the admin panel provides:

- **Dashboard**: Platform-wide statistics and metrics
- **Technicians Management**: 
  - View all pending technician registrations
  - Approve or reject technician profiles
  - Toggle technician active/inactive status
- **Service Requests**: Monitor all jobs in the system
- **Service Categories**: Manage available service types
- **Payments**: View payment transactions
- **Analytics**: Platform performance insights

## Configuration

The credentials are stored in backend `.env`:
```env
ADMIN_EMAIL=admin@sevagan.com
ADMIN_PASSWORD=Admin@123
```

To change credentials, update these values and restart the backend.

## API Endpoint

**POST** `http://localhost:3000/api/auth/admin/login`

**Request Body**:
```json
{
  "email": "admin@sevagan.com",
  "password": "Admin@123"
}
```

**Response**:
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "email": "admin@sevagan.com",
    "phone": "9999999999",
    "role": "ADMIN"
  }
}
```