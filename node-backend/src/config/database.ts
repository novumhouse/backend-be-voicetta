import { DataSource } from 'typeorm';
import dotenv from 'dotenv';
import { logger } from '../utils/logger';

dotenv.config();

if (!process.env.DATABASE_URL) {
  throw new Error('DATABASE_URL environment variable is required');
}

logger.info('Attempting to connect to database...');
logger.debug(`Database URL: ${process.env.DATABASE_URL.replace(/\/\/[^:]+:[^@]+@/, '//****:****@')}`);

export const AppDataSource = new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL,
  entities: ['src/models/**/*.ts'],
  migrations: ['src/migrations/**/*.ts'],
  subscribers: ['src/subscribers/**/*.ts'],
  synchronize: false,
  logging: process.env.NODE_ENV === 'development',
  ssl: {
    rejectUnauthorized: false
  }
});

export const initializeDatabase = async () => {
  try {
    await AppDataSource.initialize();
    logger.info('Database connection initialized');
    
    // Run migrations if in development mode
    if (process.env.NODE_ENV === 'development') {
      try {
        await AppDataSource.runMigrations();
        logger.info('Database migrations completed');
      } catch (migrationError) {
        logger.error('Migration error:', migrationError);
        throw migrationError;
      }
    }
  } catch (error) {
    logger.error('Error initializing database:', error);
    if (error instanceof Error) {
      logger.error('Error details:', {
        message: error.message,
        stack: error.stack,
        name: error.name
      });
    }
    throw error;
  }
}; 