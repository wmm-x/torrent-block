#!/bin/bash

echo "[+] Installing UFW..."
sudo apt update && sudo apt install -y ufw

echo "[+] Resetting UFW..."
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

echo "[+] Setting up UFW rules..."

# Inbound IPv4
for port in 22 8000; do sudo ufw allow in "$port"/tcp; done
sudo ufw allow in 8000/udp
for port in 2052 2053 2086 2087 2095 2096 8443 8880 8080 8888 80 443; do
    sudo ufw allow in "$port"/tcp
done

# Outbound IPv4
sudo ufw allow out 53
for port in 80 443 2052 2053 2086 2087 2095 2096 8443 8880 8080; do
    sudo ufw allow out "$port"/tcp
done

# Torrent Block (IPv4)
for rule in \
  "6881:6889/tcp" "6881:6889/udp" "6969/tcp" "51413" "1337/tcp" "2710/tcp" \
  "8999/tcp" "8999/udp" "42069/tcp" "42069/udp" "16881/tcp" "16881/udp" \
  "6880:6999/tcp" "6880:6999/udp"; do
    sudo ufw deny out $rule
done

# Media & Messaging (IPv4)
for port in 443 3478 19302; do sudo ufw allow out "$port"/udp; done
sudo ufw allow out 3478:3481/udp
sudo ufw allow out 49152:65535/udp

# Game ports (IPv4)
sudo ufw allow out 7000:7500/udp
sudo ufw allow out 10000:65535/udp
sudo ufw allow out 30000:50000/udp
sudo ufw allow out 10010:10030/udp
sudo ufw allow out 20000:20100/udp
sudo ufw allow out 1393/tcp
sudo ufw allow out 7000:8000/udp
sudo ufw allow out 8180:8181/tcp
sudo ufw allow out 10000:10010/udp
sudo ufw allow out 5222/tcp
sudo ufw allow out 5795:5847/udp
sudo ufw allow out 1024:1124/udp
sudo ufw allow out 3216:3728/udp
sudo ufw allow out 5000:5500/udp
sudo ufw allow out 8088/tcp
sudo ufw allow out 2099/tcp
sudo ufw allow out 27000:27100/udp
sudo ufw allow out 27014:27050/tcp
sudo ufw allow out 30000:30100/udp
sudo ufw allow out 5000:6000/udp
sudo ufw allow out 8000/tcp
sudo ufw allow out 8000/udp

# Inbound IPv6
for port in 22 8000; do sudo ufw allow in "$port"/tcp; done
sudo ufw allow in 8000/udp
for port in 2052 2053 2086 2087 2095 2096 8443 8880 8080 8888 80 443; do
    sudo ufw allow in "$port"/tcp
done

# Outbound IPv6
sudo ufw allow out 53
for port in 80 443 2052 2053 2086 2087 2095 2096 8443 8880 8080; do
    sudo ufw allow out "$port"/tcp
done

# Torrent Block (IPv6)
for rule in \
  "6881:6889/tcp" "6881:6889/udp" "6969/tcp" "51413" "1337/tcp" "2710/tcp" \
  "8999/tcp" "8999/udp" "42069/tcp" "42069/udp" "16881/tcp" "16881/udp" \
  "6880:6999/tcp" "6880:6999/udp"; do
    sudo ufw deny out "$rule" comment "block torrent (v6)"
done

# Media & Messaging (IPv6)
for port in 443 3478 19302; do sudo ufw allow out "$port"/udp; done
sudo ufw allow out 3478:3481/udp
sudo ufw allow out 49152:65535/udp

# Game ports (IPv6)
sudo ufw allow out 7000:7500/udp
sudo ufw allow out 10000:65535/udp
sudo ufw allow out 30000:50000/udp
sudo ufw allow out 10010:10030/udp
sudo ufw allow out 20000:20100/udp
sudo ufw allow out 1393/tcp
sudo ufw allow out 7000:8000/udp
sudo ufw allow out 8180:8181/tcp
sudo ufw allow out 10000:10010/udp
sudo ufw allow out 5222/tcp
sudo ufw allow out 5795:5847/udp
sudo ufw allow out 1024:1124/udp
sudo ufw allow out 3216:3728/udp
sudo ufw allow out 5000:5500/udp
sudo ufw allow out 8088/tcp
sudo ufw allow out 2099/tcp
sudo ufw allow out 27000:27100/udp
sudo ufw allow out 27014:27050/tcp
sudo ufw allow out 30000:30100/udp
sudo ufw allow out 5000:6000/udp
sudo ufw allow out 8000/tcp
sudo ufw allow out 8000/udp

# Enable UFW
echo "[+] Enabling UFW..."
sudo ufw logging on
sudo ufw --force enable

echo "[✓] Firewall setup complete."
sudo ufw status numbered
