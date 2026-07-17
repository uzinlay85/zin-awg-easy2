#!/bin/bash

# ==============================================================================
# Configuration Section (You only need to edit this ONCE)
# ==============================================================================
DOMAIN="vpn.yourdomain.com"
PASSWORD="YOUR_PASSWORD"

# ==============================================================================
# Automation Script (Do not edit below unless you know what you are doing)
# ==============================================================================
echo "--------------------------------------------------"
echo "Starting AmneziaWG 2.0 Web UI Automation Script"
echo "--------------------------------------------------"

echo "[1/4] Generating Password Hash..."
HASH=$(sudo docker run -i amnezia-wg-easy:2.0 wgpw "$PASSWORD" | cut -d"'" -f2)

if [ -z "$HASH" ]; then
    echo "ERROR: Failed to generate password hash. Make sure amnezia-wg-easy:2.0 image is built."
    exit 1
fi

echo "[2/4] Stopping old container if running..."
sudo docker stop amnezia-wg-easy 2>/dev/null || true
sudo docker rm amnezia-wg-easy 2>/dev/null || true

echo "[3/4] Starting new container..."
sudo docker run -d \
  --name=amnezia-wg-easy \
  -e WG_HOST="$DOMAIN" \
  -e PASSWORD_HASH="$HASH" \
  -e PORT=51831 \
  -e WG_PORT=58210 \
  -e UI_ENABLE_SORT_CLIENTS=true \
  -e UI_TRAFFIC_STATS=true \
  -e WG_ENABLE_EXPIRES_TIME=true \
  -e WG_ENABLE_ONE_TIME_LINKS=true \
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

echo "[4/4] Done! amnezia-wg-easy container has been started."
echo "--------------------------------------------------"
sudo docker ps | grep amnezia-wg-easy
