cat > /root/bbr.sh <<'SCRIPT'
#!/bin/bash

set -Ee

CONFIG="/etc/sysctl.d/99-bbr.conf"

echo "===================================="
echo "      TCP BBR Setup Script"
echo "===================================="
echo

# Check root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: Run this script as root."
    exit 1
fi

# Check kernel support
echo "[1/5] Checking kernel support..."

AVAILABLE=$(sysctl -n net.ipv4.tcp_available_congestion_control)

if ! echo "$AVAILABLE" | grep -qw bbr; then
    echo "ERROR: BBR is not available in this kernel."
    echo "Available algorithms: $AVAILABLE"
    echo "Check your kernel version and BBR support."
    exit 1
fi

echo "BBR support detected."
echo

# Back up existing configuration
echo "[2/5] Preparing configuration..."

if [ -f "$CONFIG" ]; then
    cp -n "$CONFIG" "${CONFIG}.bak" || true
fi

# Write configuration
cat > "$CONFIG" <<'EOF'
# TCP BBR configuration
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF

echo "Configuration written to $CONFIG."
echo

# Apply configuration
echo "[3/5] Applying settings..."

if ! sysctl -p "$CONFIG"; then
    echo "ERROR: Failed to apply BBR settings."
    exit 1
fi

echo

# Verify active settings
echo "[4/5] Verifying configuration..."

CC=$(sysctl -n net.ipv4.tcp_congestion_control)
QDISC=$(sysctl -n net.core.default_qdisc)

echo "TCP congestion control: $CC"
echo "Default queue discipline: $QDISC"
echo

# Check module status
echo "[5/5] Checking BBR module..."

if grep -q '^tcp_bbr ' /proc/modules 2>/dev/null; then
    echo "BBR kernel module is loaded."
elif [ -d /sys/module/tcp_bbr ]; then
    echo "BBR kernel module is available."
else
    echo "BBR may be built into the kernel."
fi

echo

# Final result
if [ "$CC" = "bbr" ] && [ "$QDISC" = "fq" ]; then
    echo "===================================="
    echo "SUCCESS: BBR is configured and active."
    echo "===================================="
else
    echo "ERROR: Configuration verification failed."
    exit 1
fi

SCRIPT

chmod +x /root/bbr.sh
bash /root/bbr.sh
