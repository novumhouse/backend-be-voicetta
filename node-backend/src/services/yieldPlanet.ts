import axios from 'axios';
import { logger } from '../utils/logger';

interface YieldPlanetConfig {
  credentials?: {
    username?: string;
    apiKey?: string;
  };
  mappings?: {
    roomTypes?: Record<string, string>;
    rateTypes?: Record<string, string>;
  };
}

export class YieldPlanetService {
  private baseUrl = 'https://api.yieldplanet.com/v1.31';
  private username: string;
  private apiKey: string;

  constructor(config?: YieldPlanetConfig) {
    this.username = config?.credentials?.username || process.env.YIELDPLANET_USERNAME!;
    this.apiKey = config?.credentials?.apiKey || process.env.YIELDPLANET_API_KEY!;

    if (!this.username || !this.apiKey) {
      throw new Error('YieldPlanet credentials not configured');
    }
  }

  private async request(method: string, endpoint: string, data?: any) {
    try {
      const response = await axios({
        method,
        url: `${this.baseUrl}${endpoint}`,
        headers: {
          'Authorization': `Basic ${Buffer.from(`${this.username}:${this.apiKey}`).toString('base64')}`,
          'Content-Type': 'application/json'
        },
        data
      });

      return response.data;
    } catch (error: any) {
      logger.error('YieldPlanet API error:', error.response?.data || error.message);
      throw error;
    }
  }

  async checkAvailability(params: {
    propertyId: string;
    checkIn: string;
    checkOut: string;
    adults: number;
    children?: number;
  }) {
    return this.request('GET', `/properties/${params.propertyId}/availability`, params);
  }

  async createReservation(params: {
    propertyId: string;
    roomTypeId: string;
    checkIn: string;
    checkOut: string;
    guestName: string;
    guestEmail: string;
    adults: number;
    children?: number;
    totalPrice: number;
    currency: string;
  }) {
    return this.request('POST', `/properties/${params.propertyId}/reservations`, params);
  }

  async modifyReservation(reservationId: string, params: {
    checkIn?: string;
    checkOut?: string;
    adults?: number;
    children?: number;
  }) {
    return this.request('PUT', `/reservations/${reservationId}`, params);
  }

  async cancelReservation(reservationId: string) {
    return this.request('DELETE', `/reservations/${reservationId}`);
  }
} 