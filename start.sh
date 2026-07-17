#!/bin/bash

# ==============================================================================
# AmneziaWG 2.0 Web UI Automation Script
# ==============================================================================
ENV_FILE="config.env"

echo "--------------------------------------------------"
echo "Starting AmneziaWG 2.0 Web UI Automation Script"
echo "--------------------------------------------------"

# Step 1: Check if config.env exists. If not, try to extract from running container
if [ ! -f "$ENV_FILE" ]; then
    echo "No $ENV_FILE found. Checking if there is an active container to restore config..."
    if sudo docker ps --format '{{.Names}}' | grep -q '^amnezia-wg-easy$'; then
        echo "Found running amnezia-wg-easy container! Extracting parameters..."
        DOMAIN=$(sudo docker inspect amnezia-wg-easy --format='{{range .Config.Env}}{{println .}}{{end}}' | grep '^WG_HOST=' | cut -d= -f2)
        HASH=$(sudo docker inspect amnezia-wg-easy --format='{{range .Config.Env}}{{println .}}{{end}}' | grep '^PASSWORD_HASH=' | cut -d= -f2)
        
        if [ -n "$DOMAIN" ] && [ -n "$HASH" ]; then
            cat << EOF > "$ENV_FILE"
WG_HOST=$DOMAIN
PASSWORD_HASH=$HASH
PORT=51831
WG_PORT=58210
UI_ENABLE_SORT_CLIENTS=true
UI_TRAFFIC_STATS=true
WG_ENABLE_EXPIRES_TIME=true
WG_ENABLE_ONE_TIME_LINKS=true
EOF
            echo "Successfully restored settings and created $ENV_FILE."
        fi
    fi
fi

# Step 2: If config.env still doesn't exist, ask the user for domain and password
if [ ! -f "$ENV_FILE" ]; then
    echo "$ENV_FILE not found and no active container detected."
    read -p "Enter your VPN Domain (e.g., vpn.yourdomain.com): " DOMAIN
    read -s -p "Enter your VPN Admin Password: " PASSWORD
    echo ""
    
    echo "Generating Password Hash..."
    HASH=$(sudo docker run -i amnezia-wg-easy:2.0 wgpw "$PASSWORD" | cut -d"'" -f2)
    
    if [ -z "$HASH" ]; then
        echo "ERROR: Failed to generate password hash. Make sure amnezia-wg-easy:2.0 image is built."
        exit 1
    fi
    
    cat << EOF > "$ENV_FILE"
WG_HOST=$DOMAIN
PASSWORD_HASH=$HASH
PORT=51831
WG_PORT=58210
UI_ENABLE_SORT_CLIENTS=true
UI_TRAFFIC_STATS=true
WG_ENABLE_EXPIRES_TIME=true
WG_ENABLE_ONE_TIME_LINKS=true
EOF
    echo "Created new $ENV_FILE file."
fi

# Load the variables
source "$ENV_FILE"

echo "Domain: $WG_HOST"

echo "Stopping old container if running..."
sudo docker stop amnezia-wg-easy 2>/dev/null || true
sudo docker rm amnezia-wg-easy 2>/dev/null || true

echo "Starting container with $ENV_FILE..."
sudo docker run -d \
  --name=amnezia-wg-easy \
  --env-file "$ENV_FILE" \
  -v /home/zinko/.amnezia-wg-easy:/etc/wireguard \
  -p 58210:58210/udp \
  -p 127.0.0.1:51831:51831/tcp \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
  --sysctl="net.ipv4.ip_forward=1" \
  --device=/dev/net/tun:/dev/net/tun \
  --restart=unless-stopped \
  amnezia-wg-easy:2.0

echo "Done! amnezia-wg-easy container is now running."
echo "--------------------------------------------------"
sudo docker ps | grep amnezia-wg-easy
