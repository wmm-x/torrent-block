cat > /root/bbr1.sh <<'SCRIPT'
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

# Detect system information
echo "[1/7] Checking system..."
echo "Kernel: $(uname -r)"
echo "Virtualization: $(systemd-detect-virt 2>/dev/null || echo unknown)"
echo

# Check whether BBR is already available
echo "[2/7] Checking BBR availability..."

AVAILABLE=$(sysctl -n net.ipv4.tcp_available_congestion_control)

if ! echo "$AVAILABLE" | grep -qw bbr; then
    echo "BBR is not currently available. Trying to load tcp_bbr..."

    if modprobe tcp_bbr 2>/dev/null; then
        echo "BBR module loaded."
    else
        echo "WARNING: Could not load tcp_bbr."
    fi

    AVAILABLE=$(sysctl -n net.ipv4.tcp_available_congestion_control)

    if ! echo "$AVAILABLE" | grep -qw bbr; then
        echo "ERROR: BBR is still unavailable."
        echo "Available algorithms: $AVAILABLE"
        echo
        echo "Check kernel module support and VPS host restrictions."
        exit 1
    fi
fi

echo "Available algorithms: $AVAILABLE"
echo "BBR support confirmed."
echo

# Make module loading persistent when a loadable module exists
echo "[3/7] Configuring module loading..."

if modinfo tcp_bbr >/dev/null 2>&1; then
    if [ -d /etc/modules-load.d ]; then
        echo "tcp_bbr" > /etc/modules-load.d/bbr.conf
        echo "Persistent module loading configured."
    fi
else
    echo "Module is not separately loadable; checking built-in support."
fi
echo

# Back up existing configuration safely
echo "[4/7] Preparing configuration..."

if [ -f "$CONFIG" ] && [ ! -f "${CONFIG}.bak" ]; then
    cp "$CONFIG" "${CONFIG}.bak"
    echo "Existing configuration backed up."
fi

cat > "$CONFIG" <<'EOF'
# TCP BBR congestion control
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF

echo "Saved configuration to $CONFIG."
echo

# Apply settings
echo "[5/7] Applying settings..."

if ! sysctl -p "$CONFIG"; then
    echo "ERROR: Failed to apply configuration."
    exit 1
fi
echo

# Verify active settings
echo "[6/7] Verifying settings..."

CC=$(sysctl -n net.ipv4.tcp_congestion_control)
QDISC=$(sysctl -n net.core.default_qdisc)

echo "TCP congestion control: $CC"
echo "Default queue discipline: $QDISC"
echo "Available algorithms: $(sysctl -n net.ipv4.tcp_available_congestion_control)"
echo

# Check module status
echo "[7/7] Checking BBR module..."

if grep -q '^tcp_bbr ' /proc/modules 2>/dev/null; then
    echo "BBR module is loaded."
elif [ -d /sys/module/tcp_bbr ]; then
    echo "BBR is present in the kernel."
else
    echo "BBR is available; module may be built into the kernel."
fi

echo

# Final result
if [ "$CC" = "bbr" ] && [ "$QDISC" = "fq" ]; then
    echo "===================================="
    echo " SUCCESS: BBR IS ACTIVE"
    echo "===================================="
    echo "Configuration persists across reboots."
else
    echo "===================================="
    echo " ERROR: VERIFICATION FAILED"
    echo "===================================="
    exit 1
fi
SCRIPT

chmod +x /root/bbr1.sh
bash /root/bbr1.sh
