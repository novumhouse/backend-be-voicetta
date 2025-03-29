import { Router } from 'express';
import { logger } from '../utils/logger';

export const healthRouter = Router();

healthRouter.get('/', (req, res) => {
  logger.debug('Health check requested');
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
}); 