# Setup script for Hetzner server
param(
    [Parameter(Mandatory=$true)]
    [string]$ServerIP,
    
    [Parameter(Mandatory=$true)]
    [string]$Domain
)

Write-Host "Setting up Hetzner server at $ServerIP..."

# 1. Create SSH config
$sshConfig = @"
Host hetzner
    HostName $ServerIP
    User root
    IdentityFile ~/.ssh/id_rsa
"@

$sshConfig | Out-File -FilePath "$env:USERPROFILE\.ssh\config" -Append

# 2. Create deployment script
$deployScript = @"
#!/bin/bash

# Update system
apt update && apt upgrade -y

# Install Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
apt install -y nodejs

# Install Nginx
apt install -y nginx

# Install Certbot
apt install -y certbot python3-certbot-nginx

# Install PM2
npm install -g pm2

# Create application directory
mkdir -p /var/www/voicetta
chown -R $USER:$USER /var/www/voicetta

# Clone repository
cd /var/www/voicetta
git clone https://github.com/yourusername/backend-be-voicetta.git .

# Install dependencies
npm ci --production

# Set up Nginx
cp nginx.conf /etc/nginx/sites-available/voicetta
ln -sf /etc/nginx/sites-available/voicetta /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Set up SSL
certbot --nginx -d $Domain

# Start application
pm2 start ecosystem.config.js
pm2 save
pm2 startup

# Reload Nginx
nginx -t && systemctl reload nginx
"@

$deployScript | Out-File -FilePath "deploy-hetzner.sh" -Encoding UTF8

# 3. Copy deployment script to server
scp deploy-hetzner.sh root@$ServerIP:/root/

# 4. Execute deployment script
ssh root@$ServerIP "bash /root/deploy-hetzner.sh"

Write-Host "Server setup completed!"
Write-Host "Next steps:"
Write-Host "1. Add your GitHub repository secrets:"
Write-Host "   - HETZNER_HOST: $ServerIP"
Write-Host "   - HETZNER_USERNAME: root"
Write-Host "   - HETZNER_SSH_KEY: Your SSH private key"
Write-Host "   - DATABASE_URL: Your database URL"
Write-Host "   - YIELDPLANET_API_URL: Your YieldPlanet API URL"
Write-Host "   - YIELDPLANET_API_KEY: Your YieldPlanet API key"
Write-Host "   - YIELDPLANET_API_SECRET: Your YieldPlanet API secret"
Write-Host "   - RETELL_WEBHOOK_SECRET: Your Retell webhook secret"
Write-Host "   - JWT_SECRET: Your JWT secret"
Write-Host "2. Push your code to GitHub"
Write-Host "3. The GitHub Action will automatically deploy to Hetzner" 