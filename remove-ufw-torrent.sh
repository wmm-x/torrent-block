#!/bin/bash

echo "[+] Removing torrent-blocking rules from UFW..."

# Get all matching torrent-related rules (TCP/UDP, port ranges, and known ports)
mapfile -t rule_numbers < <(sudo ufw status numbered | grep -E "6881|6889|6969|51413|1337|2710|8999|42069|16881|49152|65535|10000|1024" | grep -E 'ALLOW|DENY' | awk -F'[][]' '{print $2}' | sort -rn)

# Delete each matching rule by number (starting from the bottom to preserve numbering)
for rule in "${rule_numbers[@]}"; do
    echo "Deleting rule #$rule"
    sudo ufw --force delete "$rule"
done

echo "[✓] Torrent-blocking rules removed successfully."
