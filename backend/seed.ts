
import { DataSource } from 'typeorm';
import { ServiceCategory } from '../src/services/entities/service.entity';
import { User, UserRole } from '../src/users/entities/user.entity';
import * as bcrypt from 'bcrypt';
import * as dotenv from 'dotenv';
import { ServiceRequestStatus } from '../src/jobs/entities/service-request.entity';

dotenv.config();

const AppDataSource = new DataSource({
    type: 'postgres',
    host: process.env.DATABASE_HOST || 'localhost',
    port: parseInt(process.env.DATABASE_PORT) || 5432,
    username: process.env.DATABASE_USER || 'sevagan_user',
    password: process.env.DATABASE_PASSWORD || 'sevagan_password',
    database: process.env.DATABASE_NAME || 'sevagan',
    entities: [__dirname + '/../src/**/*.entity.ts'],
    synchronize: false,
});

async function seed() {
    await AppDataSource.initialize();
    console.log('Database connected for seeding...');

    const categoryRepo = AppDataSource.getRepository(ServiceCategory);
    const userRepo = AppDataSource.getRepository(User);

    // 1. Seed Service Categories
    const categories = [
        {
            name: 'Electrician',
            icon: 'electric_bolt',
            basePrice: 150,
            priceRange: '₹150 - ₹1000',
            commissionPercent: 15,
            description: 'Wiring, switch repair, fan installation, and more',
            isActive: true
        },
        {
            name: 'Plumber',
            icon: 'plumbing',
            basePrice: 150,
            priceRange: '₹150 - ₹1500',
            commissionPercent: 15,
            description: 'Leak repair, pipe fitting, tap replacement',
            isActive: true
        },
        {
            name: 'AC Service',
            icon: 'ac_unit',
            basePrice: 400,
            priceRange: '₹400 - ₹2500',
            commissionPercent: 20,
            description: 'AC cleaning, gas filling, installation',
            isActive: true
        },
        {
            name: 'Washing Machine',
            icon: 'local_laundry_service',
            basePrice: 300,
            priceRange: '₹300 - ₹3000',
            commissionPercent: 15,
            description: 'Drum cleaning, motor repair, pc board issues',
            isActive: true
        },
        {
            name: 'Bike Repair',
            icon: 'two_wheeler',
            basePrice: 200,
            priceRange: '₹200 - ₹5000',
            commissionPercent: 10,
            description: 'General service, puncture, oil change',
            isActive: true
        },
        {
            name: 'Motor Repair',
            icon: 'settings',
            basePrice: 350,
            priceRange: '₹350 - ₹2000',
            commissionPercent: 15,
            description: 'Water pump repair, coil winding',
            isActive: true
        }
    ];

    for (const cat of categories) {
        const existing = await categoryRepo.findOne({ where: { name: cat.name } });
        if (!existing) {
            await categoryRepo.save(categoryRepo.create(cat));
            console.log(`Created service category: ${cat.name}`);
        } else {
            console.log(`Service category exists: ${cat.name}`);
        }
    }

    // 2. Seed Admin User
    const adminEmail = process.env.ADMIN_EMAIL || 'admin@sevagan.com';
    const adminPhone = '9999999999';
    const adminExists = await userRepo.findOne({ where: { email: adminEmail } });

    if (!adminExists) {
        const password = await bcrypt.hash(process.env.ADMIN_PASSWORD || 'Admin@123', 10);
        const admin = userRepo.create({
            email: adminEmail,
            phone: adminPhone,
            password: password,
            role: UserRole.ADMIN,
            isPhoneVerified: true
        });
        await userRepo.save(admin);
        console.log(`Created admin user: ${adminEmail}`);
    } else {
        console.log(`Admin user already exists`);
    }

    console.log('Seeding completed!');
    await AppDataSource.destroy();
}

seed().catch((error) => {
    console.error('Error during seeding:', error);
    process.exit(1);
});
