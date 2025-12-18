import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    CreateDateColumn,
    UpdateDateColumn,
} from 'typeorm';

@Entity('service_categories')
export class ServiceCategory {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column({ unique: true })
    name: string;

    @Column()
    nameEn: string;

    @Column()
    nameTa: string;

    @Column({ nullable: true })
    description: string;

    @Column({ type: 'float' })
    basePrice: number;

    @Column({ type: 'float' })
    minPrice: number;

    @Column({ type: 'float' })
    maxPrice: number;

    @Column({ type: 'float', default: 15.0 })
    commissionPercent: number;

    @Column({ nullable: true })
    iconUrl: string;

    @Column({ default: true })
    isActive: boolean;

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}
