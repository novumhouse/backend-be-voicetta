import { Router } from 'express';
import { logger } from '../utils/logger';
import { AppError } from '../middleware/errorHandler';
import { AppDataSource } from '../config/database';
import { Property } from '../models/Property';
import { Reservation } from '../models/Reservation';
import { YieldPlanetService } from '../services/yieldPlanet';

export const webhookRouter = Router();

// Webhook handler for Retell AI
webhookRouter.post('/retell', async (req, res, next) => {
  try {
    const { propertyId, action, data } = req.body;

    logger.info(`Received webhook from Retell AI: ${action}`, { propertyId, data });

    // Validate the request
    if (!propertyId || !action || !data) {
      throw new AppError(400, 'Missing required fields');
    }

    // Find the property and its YieldPlanet configuration
    const property = await AppDataSource
      .getRepository(Property)
      .findOne({ where: { id: propertyId } });

    if (!property) {
      throw new AppError(404, 'Property not found');
    }

    const yieldPlanet = new YieldPlanetService(property.yieldPlanetConfig);

    // Handle different actions
    switch (action) {
      case 'check_availability':
        const availability = await yieldPlanet.checkAvailability({
          propertyId: property.yieldPlanetPropertyId,
          ...data
        });
        return res.json(availability);

      case 'create_reservation':
        // Map the room type if needed
        const mappedRoomType = property.yieldPlanetConfig?.mappings?.roomTypes?.[data.roomTypeId] 
          || data.roomTypeId;

        const reservation = await yieldPlanet.createReservation({
          propertyId: property.yieldPlanetPropertyId,
          ...data,
          roomTypeId: mappedRoomType
        });

        // Store the reservation in our database
        const newReservation = AppDataSource.getRepository(Reservation).create({
          ...data,
          propertyId: property.id,
          yieldPlanetReservationId: reservation.id
        });
        await AppDataSource.getRepository(Reservation).save(newReservation);

        return res.json(reservation);

      default:
        throw new AppError(400, `Unsupported action: ${action}`);
    }
  } catch (error) {
    next(error);
  }
}); 