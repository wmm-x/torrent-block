#!/bin/bash

echo "[+] Installing UFW..."
sudo apt update && sudo apt install -y ufw

echo "[+] Resetting UFW..."
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

echo "[+] Setting up UFW rules..."

# Define port rules once
INBOUND_TCP_PORTS=(22 8000 2052 2053 2086 2087 2095 2096 8443 8880 8080 8888 80 443)
INBOUND_UDP_PORTS=(8000)

OUTBOUND_DNS_PORTS=(53)
OUTBOUND_HTTP_PORTS=(80 443 2052 2053 2086 2087 2095 2096 8443 8880 8080)
OUTBOUND_UDP_MEDIA=(443 3478 19302)

TORRENT_TCP_RULES=("6881:6889" "6969" "1337" "2710" "8999" "42069" "16881")
TORRENT_UDP_RULES=("6881:6889" "8999" "42069" "16881" "6880:6999")
TORRENT_SINGLE_PORTS=(51413)

GAME_UDP_PORTS=(
  "7000:7500"
  "10000:65535"
  "30000:50000"
  "10010:10030"
  "20000:20100"
  "7000:8000"
  "10000:10010"
  "5795:5847"
  "1024:1124"
  "3216:3728"
  "5000:5500"
  "27000:27100"
  "30000:30100"
  "5000:6000"
)

GAME_TCP_PORTS=(
  "1393"
  "8180:8181"
  "5222"
  "8088"
  "2099"
  "27014:27050"
  "8000"
)

# Apply rules to both IPv4 and IPv6
apply_rules() {
  local ip_version=$1

  echo "  [*] Applying rules for $ip_version..."

  # Inbound TCP
  for port in "${INBOUND_TCP_PORTS[@]}"; do
    sudo ufw allow in on "$ip_version" "$port"/tcp 2>/dev/null
  done

  # Inbound UDP
  for port in "${INBOUND_UDP_PORTS[@]}"; do
    sudo ufw allow in on "$ip_version" "$port"/udp 2>/dev/null
  done

  # Outbound DNS
  for port in "${OUTBOUND_DNS_PORTS[@]}"; do
    sudo ufw allow out on "$ip_version" "$port" 2>/dev/null
  done

  # Outbound HTTP/HTTPS
  for port in "${OUTBOUND_HTTP_PORTS[@]}"; do
    sudo ufw allow out on "$ip_version" "$port"/tcp 2>/dev/null
  done

  # Outbound UDP Media & Messaging
  for port in "${OUTBOUND_UDP_MEDIA[@]}"; do
    sudo ufw allow out on "$ip_version" "$port"/udp 2>/dev/null
  done

  # Torrent Block - TCP
  for rule in "${TORRENT_TCP_RULES[@]}"; do
    sudo ufw deny out on "$ip_version" "$rule"/tcp comment "block torrent" 2>/dev/null
  done

  # Torrent Block - UDP
  for rule in "${TORRENT_UDP_RULES[@]}"; do
    sudo ufw deny out on "$ip_version" "$rule"/udp comment "block torrent" 2>/dev/null
  done

  # Torrent Block - Single Ports
  for port in "${TORRENT_SINGLE_PORTS[@]}"; do
    sudo ufw deny out on "$ip_version" "$port" comment "block torrent" 2>/dev/null
  done

  # UDP Media & Messaging ranges
  sudo ufw allow out on "$ip_version" 3478:3481/udp 2>/dev/null
  sudo ufw allow out on "$ip_version" 49152:65535/udp 2>/dev/null

  # Game UDP ports
  for port_range in "${GAME_UDP_PORTS[@]}"; do
    sudo ufw allow out on "$ip_version" "$port_range"/udp 2>/dev/null
  done

  # Game TCP ports
  for port_range in "${GAME_TCP_PORTS[@]}"; do
    sudo ufw allow out on "$ip_version" "$port_range"/tcp 2>/dev/null
  done
}

# Apply to both IPv4 and IPv6
apply_rules "ipv4"
apply_rules "ipv6"

# Enable UFW
echo "[+] Enabling UFW..."
sudo ufw logging on
sudo ufw --force enable

echo "[✓] Firewall setup complete."
sudo ufw status numbered
