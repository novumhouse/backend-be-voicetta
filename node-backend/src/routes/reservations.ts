import { Router } from 'express';
import { logger } from '../utils/logger';

export const reservationRouter = Router();

// Create new reservation
reservationRouter.post('/', (req, res) => {
  logger.debug('Create reservation requested');
  // TODO: Implement reservation creation
  res.status(501).json({ message: 'Not implemented yet' });
});

// Modify existing reservation
reservationRouter.put('/:id', (req, res) => {
  logger.debug(`Modify reservation ${req.params.id} requested`);
  // TODO: Implement reservation modification
  res.status(501).json({ message: 'Not implemented yet' });
}); 