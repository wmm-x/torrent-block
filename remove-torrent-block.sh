#!/bin/bash

echo "[+] Checking for iptables-persistent..."
if ! dpkg -s iptables-persistent &> /dev/null; then
    echo "[+] Installing iptables-persistent..."
    echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
    echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
    sudo DEBIAN_FRONTEND=noninteractive apt update
    sudo DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent
else
    echo "[✓] iptables-persistent already installed."
fi

echo "[+] Flushing and resetting iptables to default ACCEPT policy..."
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT

sudo ip6tables -F
sudo ip6tables -X
sudo ip6tables -t nat -F
sudo ip6tables -t mangle -F
sudo ip6tables -P INPUT ACCEPT
sudo ip6tables -P FORWARD ACCEPT
sudo ip6tables -P OUTPUT ACCEPT

echo "[+] Saving clean rules to persistent config..."
sudo iptables-save | sudo tee /etc/iptables/rules.v4 > /dev/null
sudo ip6tables-save | sudo tee /etc/iptables/rules.v6 > /dev/null

echo "[+] Restarting netfilter-persistent service..."
sudo systemctl restart netfilter-persistent 2>/dev/null || echo "[!] Warning: netfilter-persistent service not found (harmless if you're not using it)."

echo "[✓] Firewall rules removed and defaults restored."
