import { Router } from 'express';
import { logger } from '../utils/logger';

export const availabilityRouter = Router();

// Check room availability
availabilityRouter.get('/', (req, res) => {
  logger.debug('Availability check requested');
  // TODO: Implement availability check
  res.status(501).json({ message: 'Not implemented yet' });
}); 