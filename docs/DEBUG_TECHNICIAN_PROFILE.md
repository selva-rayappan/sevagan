# Quick Database Check

Run this SQL in pgAdmin to check if technician profiles exist:

```sql
-- Check all users with TECHNICIAN role
SELECT u.id, u.phone, u.role, u.name, u."createdAt"
FROM users u
WHERE u.role = 'TECHNICIAN'
ORDER BY u."createdAt" DESC;

-- Check technician profiles
SELECT t.id, t."userId", t.status, t.skills, t."createdAt",
       u.phone, u.name
FROM technicians t
LEFT JOIN users u ON t."userId" = u.id
ORDER BY t."createdAt" DESC;

-- Check if specific user has technician profile
SELECT t.*, u.phone
FROM technicians t
JOIN users u ON t."userId" = u.id
WHERE u.phone = '9442060644';
```

## If technician record exists:
Delete it to test profile creation:
```sql
DELETE FROM technicians WHERE "userId" IN (
  SELECT id FROM users WHERE phone = '9442060644'
);
```

Then refresh the app and it should show the profile setup screen.

## Root Cause
The backend might be creating a technician record automatically somewhere, or there's seed data creating it. Check the auth service to see if it auto-creates technician profiles on first login.
