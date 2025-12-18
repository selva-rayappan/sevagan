import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ServiceCategory } from './entities/service-category.entity';

@Injectable()
export class ServicesService {
    constructor(
        @InjectRepository(ServiceCategory)
        private serviceCategoryRepository: Repository<ServiceCategory>,
    ) { }

    async findAll(): Promise<ServiceCategory[]> {
        return this.serviceCategoryRepository.find({
            where: { isActive: true },
        });
    }

    async findById(id: string): Promise<ServiceCategory> {
        return this.serviceCategoryRepository.findOne({ where: { id } });
    }

    async create(data: Partial<ServiceCategory>): Promise<ServiceCategory> {
        const category = this.serviceCategoryRepository.create(data);
        return this.serviceCategoryRepository.save(category);
    }

    async update(
        id: string,
        data: Partial<ServiceCategory>,
    ): Promise<ServiceCategory> {
        await this.serviceCategoryRepository.update(id, data);
        return this.findById(id);
    }

    async delete(id: string): Promise<void> {
        await this.serviceCategoryRepository.update(id, { isActive: false });
    }
}
