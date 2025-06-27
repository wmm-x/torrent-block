#!/bin/bash

echo "[+] Installing and resetting UFW..."
sudo apt update && sudo apt install -y ufw

echo "[+] Resetting UFW to default policies..."
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

echo "[+] Allowing essential inbound rules..."
sudo ufw allow 22/tcp      # SSH
sudo ufw allow 8000/tcp    # Custom service
sudo ufw allow 8000/udp

# Allow inbound Cloudflare ports
echo "[+] Allowing inbound Cloudflare ports..."
for port in 2052 2053 2086 2087 2095 2096 8443 8880 8080 8888 80 443; do
  sudo ufw allow "$port"/tcp
done

echo "[+] Allowing essential outbound services..."
sudo ufw allow out 53                 # DNS
sudo ufw allow out 80/tcp             # HTTP
sudo ufw allow out 443/tcp            # HTTPS

# Allow Cloudflare outbound
for port in 2052 2053 2086 2087 2095 2096 8443 8880 8080; do
  sudo ufw allow out "$port"/tcp
done

echo "[+] Blocking torrent-related ports..."
# Common torrent/P2P ports
for rule in \
  "6881:6889/tcp" "6881:6889/udp" "6969/tcp" "51413" "1337/tcp" "2710/tcp" \
  "8999/tcp" "8999/udp" "42069/tcp" "42069/udp" "16881/tcp" "16881/udp" \
  "10000:65535/udp" "49152:65535/udp" "49152:65535/tcp" "6880:6999/tcp" "6880:6999/udp"; do
    sudo ufw deny out "$rule"
done
# Optional: block all high UDP ports (commented out)
# sudo ufw deny out 1024:65535/udp

echo "[+] Allowing messaging and media app ports..."
for port in 443 3478 19302; do
  sudo ufw allow out "$port"/udp
done
sudo ufw allow out 3478:3481/udp
sudo ufw allow out 49152:65535/udp

echo "[+] Allowing outbound gaming traffic..."

# Free Fire
sudo ufw allow out 7000:7500/udp
sudo ufw allow out 10000:12000/udp
sudo ufw allow out 30000:50000/udp

# PUBG
sudo ufw allow out 10010:10030/udp
sudo ufw allow out 20000:20100/udp
sudo ufw allow out 1393/tcp

# Valorant
sudo ufw allow out 7000:8000/udp
sudo ufw allow out 8180:8181/tcp
sudo ufw allow out 10000:10010/udp

# Fortnite
sudo ufw allow out 5222/tcp
sudo ufw allow out 5795:5847/udp

# Apex Legends
sudo ufw allow out 1024:1124/udp
sudo ufw allow out 3216:3728/udp

# Roblox
sudo ufw allow out 49152:65535/udp

# League of Legends
sudo ufw allow out 5000:5500/udp
sudo ufw allow out 8088/tcp
sudo ufw allow out 2099/tcp

# Steam / general
sudo ufw allow out 27000:27100/udp
sudo ufw allow out 27014:27050/tcp

# Mobile Legends
sudo ufw allow out 30000:30100/udp

# General
sudo ufw allow out 5000:6000/udp

echo "[+] Allowing outbound service on port 8000..."
sudo ufw allow out 8000/tcp
sudo ufw allow out 8000/udp

echo "[+] Enabling UFW and logging..."
sudo ufw logging on
sudo ufw --force enable

echo "[✓] UFW Status:"
sudo ufw status numbered
