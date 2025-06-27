#!/bin/bash

echo "Resetting UFW and setting default policies..."
sudo apt update && sudo apt install ufw -y
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

echo "Allowing inbound rules..."
sudo ufw allow in 22/tcp
sudo ufw allow in 8000/tcp
sudo ufw allow in 8000/udp

# Inbound Cloudflare ports
for port in 2052 2053 2086 2087 2095 2096 8443 8880 8080 8888 80 443; do
  sudo ufw allow in $port/tcp
done

echo "Allowing essential outbound rules..."
sudo ufw allow out 53                  # DNS
sudo ufw allow out 80/tcp              # HTTP
sudo ufw allow out 443/tcp             # HTTPS

# Cloudflare outbound
for port in 2052 2053 2086 2087 2095 2096 8443 8880 8080; do
  sudo ufw allow out $port/tcp
done

echo "Blocking torrent ports..."
# Common BitTorrent client ports
sudo ufw deny out 6881:6889/tcp
sudo ufw deny out 6881:6889/udp
sudo ufw deny out 6969/tcp
sudo ufw deny out 51413                # Transmission default
sudo ufw deny out 1337/tcp             # General P2P
sudo ufw deny out 2710/tcp             # UDP Tracker Port
sudo ufw deny out 8999/tcp
sudo ufw deny out 8999/udp
sudo ufw deny out 42069/tcp
sudo ufw deny out 42069/udp
sudo ufw deny out 16881/tcp
sudo ufw deny out 16881/udp
sudo ufw deny out 10000:65535/udp
sudo ufw deny out 49152:65535/udp
sudo ufw deny out 49152:65535/tcp
sudo ufw deny out 6880:6999/tcp
sudo ufw deny out 6880:6999/udp
#sudo ufw deny out 1024:65535/udp       # block high UDP for DHT

echo "Allowing messaging & media apps..."
sudo ufw allow out 443/udp
sudo ufw allow out 3478/udp
sudo ufw allow out 19302/udp
sudo ufw allow out 3478:3481/udp
sudo ufw allow out 49152:65535/udp

echo "Allowing gaming ports..."

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

# General game traffic
sudo ufw allow out 5000:6000/udp

echo "Allowing outbound for service on port 8000..."
sudo ufw allow out 8000/tcp
sudo ufw allow out 8000/udp

echo "Enabling UFW and logging..."
sudo ufw logging on
sudo ufw --force enable
sudo ufw status numbered
