import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import { rateLimit } from 'express-rate-limit';
import swaggerUi from 'swagger-ui-express';
import { errorHandler } from './middleware/errorHandler';
import { logger } from './utils/logger';
import { healthRouter } from './routes/health';
import { reservationRouter } from './routes/reservations';
import { availabilityRouter } from './routes/availability';
import { propertyRouter } from './routes/properties';
import { webhookRouter } from './routes/webhook';
import { initializeDatabase } from './config/database';

dotenv.config();

const app = express();
const port = Number(process.env.PORT) || 3000;
const host = '0.0.0.0'; // Listen on all interfaces

// Basic security middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use(limiter);

// Routes
app.use('/api/health', healthRouter);
app.use('/api/reservations', reservationRouter);
app.use('/api/availability', availabilityRouter);
app.use('/api/properties', propertyRouter);
app.use('/api/webhook', webhookRouter);

// Error handling
app.use(errorHandler);

// Initialize database and start server
const startServer = async () => {
  try {
    logger.info('Starting server initialization...');
    await initializeDatabase();
    logger.info('Database initialized, starting HTTP server...');
    app.listen(port, host, () => {
      logger.info(`Server is running on http://${host}:${port}`);
      logger.info('Available routes:');
      logger.info('- GET /api/health');
      logger.info('- POST /api/reservations');
      logger.info('- GET /api/availability');
      logger.info('- GET /api/properties');
      logger.info('- POST /api/webhook');
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer(); 