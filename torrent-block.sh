#!/bin/bash

echo "[+] Installing iptables-persistent..."
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent

echo "[+] Resetting iptables rules..."
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT

echo "[+] Blocking torrent ports..."
sudo iptables -A OUTPUT -p tcp --dport 6881:6999 -j DROP
sudo iptables -A OUTPUT -p udp --dport 6881:6999 -j DROP
sudo iptables -A INPUT  -p tcp --dport 6881:6999 -j DROP
sudo iptables -A INPUT  -p udp --dport 6881:6999 -j DROP

sudo iptables -A OUTPUT -p tcp --dport 51413 -j DROP
sudo iptables -A OUTPUT -p udp --dport 51413 -j DROP
sudo iptables -A INPUT  -p tcp --dport 51413 -j DROP
sudo iptables -A INPUT  -p udp --dport 51413 -j DROP

echo "[+] Blocking torrent protocols via DPI..."
for keyword in "BitTorrent" "BitTorrent protocol" "peer_id=" ".torrent" "announce" "info_hash" "tracker" "get_peers" "find_node" "announce_peer" "BitComet" "uTorrent" "magnet:"; do
    sudo iptables -A FORWARD -m string --string "$keyword" --algo bm -j DROP
    sudo iptables -A OUTPUT  -m string --string "$keyword" --algo bm -j DROP
    sudo iptables -A INPUT   -m string --string "$keyword" --algo bm -j DROP
done

echo "[+] Blocking DHT UDP (often used for peer discovery)..."
sudo iptables -A FORWARD -p udp --dport 6881:6999 -j DROP
sudo iptables -A OUTPUT  -p udp --dport 6881:6999 -j DROP
sudo iptables -A INPUT   -p udp --dport 6881:6999 -j DROP

echo "[+] Optional: Drop new outbound UDP with high ports (DHT/WebRTC risk)..."
sudo iptables -A OUTPUT -p udp --dport 33434:65535 -m conntrack --ctstate NEW -j DROP

echo "[✓] Torrent traffic blocking ENABLED."

echo "[+] Saving rules to persistent config..."
sudo iptables-save | sudo tee /etc/iptables/rules.v4 > /dev/null
sudo ip6tables-save | sudo tee /etc/iptables/rules.v6 > /dev/null

sudo systemctl restart netfilter-persistent
echo "[✓] Firewall rules saved and reloaded."
