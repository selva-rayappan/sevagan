import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Customer } from './entities/customer.entity';

@Injectable()
export class CustomersService {
    constructor(
        @InjectRepository(Customer)
        private customerRepository: Repository<Customer>,
    ) { }

    async findByUserId(userId: string): Promise<Customer> {
        const customer = await this.customerRepository.findOne({
            where: { userId },
            relations: ['user'],
        });

        if (!customer) {
            throw new NotFoundException('Customer profile not found');
        }

        return customer;
    }

    async createProfile(userId: string, data: Partial<Customer>): Promise<Customer> {
        const customer = this.customerRepository.create({
            ...data,
            userId,
        });

        return this.customerRepository.save(customer);
    }

    async updateProfile(userId: string, data: Partial<Customer>): Promise<Customer> {
        const customer = await this.findByUserId(userId);

        Object.assign(customer, data);

        return this.customerRepository.save(customer);
    }

    async profileExists(userId: string): Promise<boolean> {
        const count = await this.customerRepository.count({
            where: { userId },
        });

        return count > 0;
    }
}
