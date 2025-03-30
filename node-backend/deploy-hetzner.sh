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
chown -R ${USER}:${USER} /var/www/voicetta

# Clone repository
cd /var/www/voicetta
git clone https://github.com/novumhouse/backend-be-voicetta.git .

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
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

ln -sf /etc/nginx/sites-available/voicetta /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Start application
pm2 start ecosystem.config.js
pm2 save
pm2 startup

# Reload Nginx
nginx -t && systemctl reload nginx

echo "Server setup completed successfully!"
echo "Your backend should be accessible at http://YOUR_IP/api"
echo "Don't forget to update the .env file with your actual credentials"

