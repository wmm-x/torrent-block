#!/bin/bash
set -e

echo "[*] Stopping and disabling systemd-resolved..."
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved

echo "[*] Removing existing resolv.conf (if any)..."
sudo rm -f /etc/resolv.conf

echo "[*] Adding Google and Cloudflare DNS servers..."
echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" | sudo tee /etc/resolv.conf > /dev/null

echo "[*] Locking resolv.conf to prevent changes..."
sudo chattr +i /etc/resolv.conf

echo "[*] Verifying DNS settings..."
cat /etc/resolv.conf

echo "[*] Checking if port 53 is free..."
sudo ss -tulpn | grep :53 || echo "Port 53 is now free."

echo "[*] Done. You can now run services that need port 53."
