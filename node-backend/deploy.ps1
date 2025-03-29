# Deployment script for Hetzner
Write-Host "Starting deployment process..."

# 1. Build the application
Write-Host "Building application..."
npm run build

# 2. Create production .env file
Write-Host "Creating production .env file..."
$envContent = @"
# Server Configuration
PORT=3000
NODE_ENV=production
LOG_LEVEL=info

# Database Configuration
DATABASE_URL=$env:DATABASE_URL

# YieldPlanet API Configuration
YIELDPLANET_API_URL=$env:YIELDPLANET_API_URL
YIELDPLANET_API_KEY=$env:YIELDPLANET_API_KEY
YIELDPLANET_API_SECRET=$env:YIELDPLANET_API_SECRET

# Retell AI Configuration
RETELL_WEBHOOK_SECRET=$env:RETELL_WEBHOOK_SECRET

# JWT Configuration
JWT_SECRET=$env:JWT_SECRET
JWT_EXPIRES_IN=1h

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
"@

$envContent | Out-File -FilePath ".env.production" -Encoding UTF8

# 3. Install PM2 globally if not already installed
Write-Host "Installing PM2..."
npm install -g pm2

# 4. Create PM2 ecosystem file
Write-Host "Creating PM2 ecosystem file..."
$ecosystemContent = @"
module.exports = {
  apps: [{
    name: 'voicetta-backend',
    script: 'dist/server.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production'
    },
    env_production: {
      NODE_ENV: 'production'
    }
  }]
}
"@

$ecosystemContent | Out-File -FilePath "ecosystem.config.js" -Encoding UTF8

Write-Host "Deployment script completed successfully!" 