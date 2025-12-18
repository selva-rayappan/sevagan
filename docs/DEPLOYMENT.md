# Sevagan Platform - Deployment Guide

## Prerequisites

- Docker and Docker Compose
- Node.js 18+ (for local development)
- Flutter 3.16+ (for mobile apps)
- PostgreSQL 14+
- Redis 7+
- AWS Account (for production deployment)

## Local Development Setup

### 1. Backend Setup

```bash
cd backend
cp .env.example .env
# Edit .env with your local configuration
npm install
npm run start:dev
```

The backend will be available at `http://localhost:3000`
API documentation at `http://localhost:3000/api/docs`

### 2. Database Setup

Using Docker Compose:
```bash
docker-compose up -d postgres redis
```

Run migrations:
```bash
cd backend
npm run migration:run
```

### 3. Admin Panel Setup

```bash
cd admin-panel
cp .env.example .env
npm install
npm run dev
```

Admin panel will be available at `http://localhost:5173`

### 4. Flutter Apps Setup

#### Customer App
```bash
cd customer_app
flutter pub get
flutter run
```

#### Technician App
```bash
cd technician_app
flutter pub get
flutter run
```

## Production Deployment (AWS)

### Architecture

- **EC2**: Application servers
- **RDS**: PostgreSQL database
- **ElastiCache**: Redis
- **S3**: File storage
- **CloudFront**: CDN (optional)

### Step 1: Database Setup

1. Create RDS PostgreSQL instance
2. Note down the endpoint, username, and password
3. Create ElastiCache Redis cluster
4. Note down the Redis endpoint

### Step 2: S3 Bucket

1. Create S3 bucket for file uploads
2. Configure bucket policy for public read access
3. Note down bucket name and region

### Step 3: EC2 Instance

1. Launch EC2 instance (t3.medium or larger)
2. Install Docker and Docker Compose
3. Configure security groups:
   - Port 80 (HTTP)
   - Port 443 (HTTPS)
   - Port 3000 (Backend API)

### Step 4: Environment Configuration

Create `.env` file on EC2 instance:

```bash
# Database
DATABASE_HOST=<rds-endpoint>
DATABASE_PORT=5432
DATABASE_NAME=sevagan
DATABASE_USER=<db-username>
DATABASE_PASSWORD=<db-password>

# Redis
REDIS_HOST=<elasticache-endpoint>
REDIS_PORT=6379

# JWT
JWT_SECRET=<generate-secure-secret>
JWT_EXPIRATION=7d

# AWS S3
AWS_S3_ACCESS_KEY_ID=<your-access-key>
AWS_S3_SECRET_ACCESS_KEY=<your-secret-key>
AWS_S3_REGION=us-east-1
AWS_S3_BUCKET_NAME=<your-bucket-name>

# Razorpay
RAZORPAY_KEY_ID=<your-razorpay-key>
RAZORPAY_KEY_SECRET=<your-razorpay-secret>

# Firebase
FIREBASE_PROJECT_ID=<your-project-id>
FIREBASE_PRIVATE_KEY=<your-private-key>
FIREBASE_CLIENT_EMAIL=<your-client-email>
```

### Step 5: Deploy Application

```bash
# Clone repository
git clone <repository-url>
cd sevagan

# Build and start services
docker-compose -f docker-compose.prod.yml up -d

# Run database migrations
docker-compose exec backend npm run migration:run
```

### Step 6: Mobile App Deployment

#### Android (Customer & Technician Apps)

1. Update API endpoint in app configuration
2. Build release APK:
   ```bash
   flutter build apk --release
   ```
3. Upload to Google Play Store

## SSL/HTTPS Setup

Use Let's Encrypt with Certbot:

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

## Monitoring

### Logs

```bash
# Backend logs
docker-compose logs -f backend

# Admin panel logs
docker-compose logs -f admin-panel

# Database logs
docker-compose logs -f postgres
```

### Health Checks

- Backend: `http://your-domain.com/api/health`
- Admin Panel: `http://your-domain.com/admin`

## Backup Strategy

### Database Backup

```bash
# Automated daily backup
pg_dump -h <rds-endpoint> -U <username> sevagan > backup_$(date +%Y%m%d).sql
```

### S3 Backup

Enable versioning on S3 bucket for automatic file backups.

## Scaling

### Horizontal Scaling

1. Use Application Load Balancer (ALB)
2. Launch multiple EC2 instances
3. Configure auto-scaling group

### Database Scaling

1. Use RDS read replicas for read-heavy workloads
2. Enable Multi-AZ for high availability

## Troubleshooting

### Backend not starting

- Check database connection
- Verify environment variables
- Check logs: `docker-compose logs backend`

### Mobile app can't connect

- Verify API endpoint configuration
- Check CORS settings in backend
- Ensure SSL certificate is valid

### Redis connection issues

- Verify ElastiCache security group
- Check Redis endpoint and port
- Test connection: `redis-cli -h <endpoint> ping`

## Support

For issues and questions, refer to the main README.md or create an issue in the repository.
