# Setup script for Windows to prepare for Hetzner deployment
Write-Host "Starting setup process..."

# 1. Check if Node.js is installed
Write-Host "Checking Node.js installation..."
$nodeVersion = node --version
if ($nodeVersion) {
    Write-Host "Node.js is installed: $nodeVersion"
} else {
    Write-Host "Node.js is not installed. Please install Node.js 20.x from https://nodejs.org/"
    exit 1
}

# 2. Install dependencies
Write-Host "Installing dependencies..."
npm install

# 3. Build the application
Write-Host "Building application..."
npm run build

# 4. Create production .env file
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

# 5. Create deployment package
Write-Host "Creating deployment package..."
$deployDir = "deploy"
if (Test-Path $deployDir) {
    Remove-Item -Path $deployDir -Recurse -Force
}
New-Item -ItemType Directory -Path $deployDir

# Copy necessary files
Copy-Item -Path "dist" -Destination "$deployDir/dist" -Recurse
Copy-Item -Path "package.json" -Destination "$deployDir/"
Copy-Item -Path "package-lock.json" -Destination "$deployDir/"
Copy-Item -Path ".env.production" -Destination "$deployDir/.env"
Copy-Item -Path "ecosystem.config.js" -Destination "$deployDir/"
Copy-Item -Path "nginx.conf" -Destination "$deployDir/"

# Create deployment instructions
$instructions = @"
# Deployment Instructions for Hetzner

1. Connect to your Hetzner server:
   ssh root@your-server-ip

2. Install required packages:
   apt update && apt upgrade -y
   apt install -y nodejs npm nginx certbot python3-certbot-nginx

3. Create application directory:
   mkdir -p /var/www/voicetta
   chown -R $USER:$USER /var/www/voicetta

4. Copy deployment files to server:
   scp -r deploy/* root@your-server-ip:/var/www/voicetta/

5. On the server:
   cd /var/www/voicetta
   npm install --production
   cp nginx.conf /etc/nginx/sites-available/voicetta
   ln -s /etc/nginx/sites-available/voicetta /etc/nginx/sites-enabled/
   rm /etc/nginx/sites-enabled/default
   certbot --nginx -d api.yourdomain.com
   npm install -g pm2
   pm2 start ecosystem.config.js
   pm2 save
   pm2 startup
"@

$instructions | Out-File -FilePath "$deployDir/DEPLOY.md" -Encoding UTF8

Write-Host "Setup completed successfully! Check the 'deploy' directory for deployment files." 