# Sevagan - Hyperlocal Services Platform

A production-ready on-demand hyperlocal services platform connecting customers with local technicians for services like electrical, plumbing, AC repair, motor repair, washing machine repair, and bike repair.

## 🏗️ Architecture

### Components

- **Backend**: Node.js (NestJS) + PostgreSQL + Redis
- **Customer App**: Flutter (Android)
- **Technician App**: Flutter (Android)
- **Admin Panel**: React (Vite)

### Key Features

- 🔐 JWT Authentication with OTP
- 📍 Real-time job matching based on location
- 💳 Payment integration (Cash + Razorpay UPI)
- 🗺️ Google Maps integration for live tracking
- 🔔 Push notifications via Firebase Cloud Messaging
- 🌐 Tamil + English localization
- 👨‍💼 Admin dashboard with analytics

## 📁 Project Structure

```
sevagan/
├── backend/                 # NestJS backend API
├── customer_app/           # Flutter customer mobile app
├── technician_app/         # Flutter technician mobile app
├── admin-panel/            # React admin web panel
├── deployment/             # Deployment scripts and configs
├── docs/                   # Documentation
├── docker-compose.yml      # Local development setup
└── README.md
```

## 🚀 Quick Start

### Prerequisites

- Node.js 18+
- PostgreSQL 14+
- Redis 7+
- Flutter 3.16+
- Docker & Docker Compose (for local development)

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd sevagan
   ```

2. **Start backend services**
   ```bash
   docker-compose up -d
   cd backend
   npm install
   npm run migration:run
   npm run start:dev
   ```

3. **Run customer app**
   ```bash
   cd customer_app
   flutter pub get
   flutter run
   ```

4. **Run technician app**
   ```bash
   cd technician_app
   flutter pub get
   flutter run
   ```

5. **Run admin panel**
   ```bash
   cd admin-panel
   npm install
   npm run dev
   ```

## 📚 Documentation

- [API Documentation](docs/API.md)
- [Deployment Guide](docs/DEPLOYMENT.md)
- [Database Schema](docs/DATABASE.md)
- [Architecture Overview](docs/ARCHITECTURE.md)

## 🔑 Environment Variables

Each component requires environment variables. See `.env.example` files in respective directories:

- `backend/.env.example`
- `customer_app/.env.example`
- `technician_app/.env.example`
- `admin-panel/.env.example`

## 🧪 Testing

```bash
# Backend tests
cd backend
npm test
npm run test:e2e

# Flutter tests
cd customer_app
flutter test

cd technician_app
flutter test

# Admin panel tests
cd admin-panel
npm test
```

## 📦 Deployment

See [DEPLOYMENT.md](docs/DEPLOYMENT.md) for detailed deployment instructions for:
- AWS (EC2, RDS, S3)
- DigitalOcean
- Docker-based deployment

## 🛠️ Tech Stack

### Backend
- NestJS (TypeScript)
- PostgreSQL
- Redis
- TypeORM
- JWT
- Razorpay SDK
- Firebase Admin SDK

### Mobile Apps
- Flutter
- Provider (state management)
- Google Maps Flutter
- Firebase Messaging
- Razorpay Flutter
- HTTP client

### Admin Panel
- React
- Vite
- TailwindCSS
- React Router
- Axios
- Recharts

## 📄 License

MIT

## 👥 Support

For issues and questions, please open an issue in the repository.
