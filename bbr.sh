```bash
#!/bin/bash

set -e

CONFIG="/etc/sysctl.d/99-bbr.conf"

echo "===================================="
echo "   TCP BBR Configuration Script"
echo "===================================="

# Check root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or using sudo."
    exit 1
fi

# Create BBR configuration
echo "[1/4] Creating BBR configuration..."

cat > "$CONFIG" <<EOF
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF

# Apply configuration
echo "[2/4] Applying sysctl settings..."
sysctl -p "$CONFIG"

# Verify congestion control
echo "[3/4] Checking TCP congestion control..."
sysctl net.ipv4.tcp_congestion_control

# Verify available congestion control algorithms
echo ""
echo "Available TCP congestion control algorithms:"
sysctl net.ipv4.tcp_available_congestion_control

# Check BBR kernel module
echo ""
echo "[4/4] Checking BBR kernel module..."
if lsmod | grep -q '^tcp_bbr'; then
    echo "BBR kernel module is loaded."
else
    echo "BBR module is not listed by lsmod."
    echo "BBR may be built into the kernel or unavailable."
fi

# Final verification
echo ""
if [ "$(sysctl -n net.ipv4.tcp_congestion_control)" = "bbr" ] &&
   [ "$(sysctl -n net.core.default_qdisc)" = "fq" ]; then
    echo "SUCCESS: BBR and FQ are configured."
else
    echo "WARNING: BBR configuration could not be fully verified."
    exit 1
fi
```
