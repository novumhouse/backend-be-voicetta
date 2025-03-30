# Setup script for Hetzner server
param(
    [Parameter(Mandatory=$true)]
    [string]$ServerIP,
    
    [Parameter(Mandatory=$false)]
    [string]$Domain,

    [Parameter(Mandatory=$false)]
    [string]$GitHubRepo = "novumhouse/backend-be-voicetta"
)

Write-Host "Setting up Hetzner server at $ServerIP..."

# Define SSH key paths
$sshDir = Join-Path $env:USERPROFILE ".ssh"
$privateKeyPath = Join-Path $sshDir "hetzner_ed25519"
$publicKeyPath = Join-Path $sshDir "hetzner_ed25519.pub"

# Check if the key exists
if (-not (Test-Path $privateKeyPath)) {
    Write-Host "Error: SSH key not found at $privateKeyPath" -ForegroundColor Red
    Write-Host "Please make sure the key exists or update the script to use a different key." -ForegroundColor Red
    exit 1
}

# Create SSH config
$sshConfig = @"
Host hetzner
    HostName $ServerIP
    User root
    PubkeyAuthentication yes
    IdentityFile ~/.ssh/hetzner_ed25519
    StrictHostKeyChecking no
"@

# Create config file
$configPath = Join-Path $sshDir "config"
$sshConfig | Out-File -FilePath $configPath -Encoding UTF8 -Force

Write-Host "SSH config created at $configPath"

# Try to connect
Write-Host "Attempting to connect to the server..."
$testConnection = ssh -i $privateKeyPath -o "StrictHostKeyChecking=no" root@$ServerIP "echo 'SSH connection successful'" 2>&1

if ($testConnection -like "*SSH connection successful*") {
    Write-Host "SSH connection successful!"

    # Create the deployment script directly on the server
    Write-Host "Creating deployment script on server..."
    
    # Create the script content - make sure to replace the GitHub repo
    $deployScriptContent = @"
#!/bin/bash

# Update system
apt update && apt upgrade -y

# Install Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# Install Nginx
apt install -y nginx

# Install PM2
npm install -g pm2

# Create application directory
mkdir -p /var/www/voicetta
chown -R \${USER}:\${USER} /var/www/voicetta

# Clone repository
cd /var/www/voicetta
if [ ! -d .git ]; then
  git clone https://github.com/$GitHubRepo .
else
  cd /var/www/voicetta
  git pull
fi

# Install dependencies
npm ci --production

# Set up environment file
cat > .env << EOF
NODE_ENV=production
PORT=3000
DATABASE_URL=YOUR_DATABASE_URL
YIELDPLANET_USERNAME=YOUR_YIELDPLANET_USERNAME
YIELDPLANET_PASSWORD=YOUR_YIELDPLANET_PASSWORD
RETELL_API_KEY=YOUR_RETELL_API_KEY
JWT_SECRET=YOUR_JWT_SECRET
EOF

# Create ecosystem.config.js if it doesn't exist
if [ ! -f ecosystem.config.js ]; then
  cat > ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: "voicetta",
    script: "dist/index.js",
    env: {
      NODE_ENV: "production",
      PORT: 3000
    },
    instances: "max",
    exec_mode: "cluster",
    watch: false,
    max_memory_restart: "500M"
  }]
}
EOF
fi

# Set up Nginx
cat > /etc/nginx/sites-available/voicetta << 'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

ln -sf /etc/nginx/sites-available/voicetta /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Start application
pm2 start ecosystem.config.js || pm2 reload ecosystem.config.js
pm2 save
pm2 startup

# Reload Nginx
nginx -t && systemctl reload nginx

echo "Server setup completed successfully!"
echo "Your backend should be accessible at http://$ServerIP/api"
echo "Don't forget to update the .env file with your actual credentials"
"@

    # Use a heredoc to create the script on the server
    $command = @"
cat > /root/deploy-hetzner.sh << 'DEPLOYEOF'
$deployScriptContent
DEPLOYEOF
chmod +x /root/deploy-hetzner.sh
"@

    # Execute command to create script
    ssh -i $privateKeyPath -o "StrictHostKeyChecking=no" root@$ServerIP $command

    # Execute deployment script
    Write-Host "Executing deployment script on server..."
    ssh -i $privateKeyPath -o "StrictHostKeyChecking=no" root@$ServerIP "bash /root/deploy-hetzner.sh"

    Write-Host "Server setup completed!"
    Write-Host "Next steps:"
    Write-Host "1. Add your GitHub repository secrets:"
    Write-Host "   - HETZNER_HOST: $ServerIP"
    Write-Host "   - HETZNER_USERNAME: root"
    Write-Host "   - HETZNER_SSH_KEY: $(Get-Content $privateKeyPath)"
    Write-Host "   - DATABASE_URL: Your database URL"
    Write-Host "   - YIELDPLANET_USERNAME: Your YieldPlanet username"
    Write-Host "   - YIELDPLANET_PASSWORD: Your YieldPlanet password"
    Write-Host "   - RETELL_API_KEY: Your Retell API key"
    Write-Host "   - JWT_SECRET: Your JWT secret"
    Write-Host "2. Push your code to GitHub"
    Write-Host "3. The GitHub Action will automatically deploy to Hetzner"
    Write-Host "4. Test your API at http://$ServerIP/api/health"
} else {
    Write-Host "SSH connection failed. Please check your SSH key and server configuration." -ForegroundColor Red
    Write-Host "Error details: $testConnection" -ForegroundColor Red
} 