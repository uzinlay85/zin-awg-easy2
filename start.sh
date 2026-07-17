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

# Step 3: Automatic wg0.json migration (DPI Bypass range and signature updates)
echo "Checking for wg0.json configuration file to auto-update..."
WG_JSON_PATH=$(find /home /root -name "wg0.json" 2>/dev/null | head -n 1)

if [ -n "$WG_JSON_PATH" ] && [ -f "$WG_JSON_PATH" ]; then
    echo "Found wg0.json at: $WG_JSON_PATH"
    
    # Run inline Node.js migration script
    node -e '
const fs = require("fs");
const filePath = process.argv[1];
try {
  const data = JSON.parse(fs.readFileSync(filePath, "utf8"));
  if (data && data.server) {
    const h1 = String(data.server.h1 || "");
    // If h1 is not a range (i.e. does not contain "-"), we need to migrate it to AWG 2.0 ranges and QUIC signatures
    if (!h1.includes("-")) {
      console.log("Migrating wg0.json to new range-based headers and QUIC signatures...");
      data.server.h1 = "100500-100600";
      data.server.h2 = "100000500-100000600";
      data.server.h3 = "200000500-200000502";
      data.server.h4 = "300000500-400000500";
      data.server.i1 = "<b 0xc700000001><rc 8><t><r 100>";
      data.server.i2 = "<b 0xf6ab3267fa><t><rc 20><r 80>";
      data.server.i3 = "";
      data.server.i4 = "";
      data.server.i5 = "";
      fs.writeFileSync(filePath, JSON.stringify(data, null, 2), "utf8");
      console.log("[SUCCESS] wg0.json configuration updated.");
    } else {
      console.log("wg0.json is already using range-based headers. No migration needed.");
    }
  }
} catch (err) {
  console.error("[ERROR] Failed to parse or update wg0.json:", err.message);
}
' "$WG_JSON_PATH"
else
    echo "No wg0.json found yet. (This is normal for fresh installations)."
fi

echo "Domain: $WG_HOST"

echo "Stopping old container if running..."
sudo docker stop amnezia-wg-easy 2>/dev/null || true
sudo docker rm amnezia-wg-easy 2>/dev/null || true

# Determine volume source directory dynamically
VOL_DIR=$(dirname "$WG_JSON_PATH")
if [ -z "$VOL_DIR" ] || [ ! -d "$VOL_DIR" ]; then
    # Fallback to default if no wg0.json was found
    VOL_DIR="/home/zinko/.amnezia-wg-easy"
    if [ ! -d "/home/zinko" ]; then
        VOL_DIR="/root/.amnezia-wg-easy"
    fi
fi

echo "Starting container with volume mapping: $VOL_DIR -> /etc/wireguard"
sudo docker run -d \
  --name=amnezia-wg-easy \
  --env-file "$ENV_FILE" \
  -v "$VOL_DIR:/etc/wireguard" \
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
