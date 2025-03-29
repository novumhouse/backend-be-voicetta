# Voicetta Backend

Node.js/Express backend for the Voicetta Booking Engine middleware that connects Retell AI voicebots to YieldPlanet API.

## Prerequisites

- Node.js >= 18.0.0
- npm (comes with Node.js)
- PostgreSQL >= 12

## Quick Start

### Windows

```powershell
# Navigate to backend directory
cd node-backend

# Run setup script
.\setup.ps1
```

### Linux/MacOS

```bash
# Navigate to backend directory
cd node-backend

# Install dependencies
npm install

# Create necessary directories
mkdir -p logs dist

# Copy environment file
cp src/.env.example src/.env

# Create database
createdb voicetta

# Run migrations
npm run migration:run

# Start development server
npm run dev
```

## Database Setup

1. Create the database:
   ```bash
   createdb voicetta
   ```

2. Configure database connection in `.env`:
   ```env
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=voicetta
   DB_USER=your_username
   DB_PASSWORD=your_password
   ```

3. Run migrations:
   ```bash
   npm run migration:run
   ```

### Migration Commands

- Generate a new migration:
  ```bash
  npm run migration:generate -- src/migrations/MigrationName
  ```

- Create a blank migration:
  ```bash
  npm run migration:create -- src/migrations/MigrationName
  ```

- Run pending migrations:
  ```bash
  npm run migration:run
  ```

- Revert last migration:
  ```bash
  npm run migration:revert
  ```

## API Endpoints

### Health Check
- GET `/api/health` - Service health status

### Properties
- GET `/api/properties/:id` - Get property details
- GET `/api/properties` - List all properties

### Reservations
- POST `/api/reservations` - Create new reservation
- PUT `/api/reservations/:id` - Update reservation
- GET `/api/reservations/:id` - Get reservation details
- GET `/api/reservations` - List reservations

### Availability
- GET `/api/availability` - Check room availability
  - Query params:
    - propertyId: string
    - checkIn: string (YYYY-MM-DD)
    - checkOut: string (YYYY-MM-DD)
    - adults: number
    - children?: number

## Environment Variables

```env
# Server Configuration
PORT=3000
NODE_ENV=development
LOG_LEVEL=debug

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=voicetta
DB_USER=postgres
DB_PASSWORD=your_password

# YieldPlanet API Configuration
YIELDPLANET_API_URL=https://api.yieldplanet.com/v1.31
YIELDPLANET_API_KEY=your_api_key
YIELDPLANET_API_SECRET=your_api_secret

# Retell AI Configuration
RETELL_WEBHOOK_SECRET=your_webhook_secret

# JWT Configuration
JWT_SECRET=your_jwt_secret
JWT_EXPIRES_IN=1h

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000  # 15 minutes
RATE_LIMIT_MAX_REQUESTS=100
```

## Available Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Build for production
- `npm start` - Run production build
- `npm test` - Run tests
- `npm run lint` - Run linter
- `npm run format` - Format code

## Project Structure

```
node-backend/
├── src/
│   ├── config/         # Configuration files
│   ├── middleware/     # Express middleware
│   ├── migrations/     # Database migrations
│   ├── models/        # TypeORM entities
│   ├── routes/        # API routes
│   ├── services/      # Business logic
│   ├── utils/         # Utility functions
│   ├── .env           # Environment variables
│   └── server.ts      # Application entry point
├── logs/              # Application logs
├── dist/             # Compiled code
└── tests/            # Test files
```

## Error Handling

The API uses standard HTTP status codes and returns errors in the following format:

```json
{
  "status": "error",
  "message": "Error description",
  "code": "ERROR_CODE"
}
```

## Logging

Logs are stored in the `logs` directory:
- `logs/error.log` - Error logs only
- `logs/combined.log` - All logs

## Contributing

1. Create a new branch for your feature
2. Make your changes
3. Run tests and linting
4. Submit a pull request

## License

This project is proprietary software. All rights reserved. 