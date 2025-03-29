import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('request_logs')
export class RequestLog {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({
    type: 'enum',
    enum: ['yieldplanet', 'retell']
  })
  service!: 'yieldplanet' | 'retell';

  @Column()
  endpoint!: string;

  @Column()
  method!: string;

  @Column({ type: 'jsonb', nullable: true })
  requestHeaders?: Record<string, string>;

  @Column('jsonb', { nullable: true })
  requestBody?: any;

  @Column({ type: 'jsonb', nullable: true })
  responseHeaders?: Record<string, string>;

  @Column('jsonb', { nullable: true })
  responseBody?: any;

  @Column({ nullable: true })
  statusCode?: number;

  @Column()
  duration!: number;

  @Column({ nullable: true })
  error?: string;

  @CreateDateColumn()
  createdAt!: Date;
} 