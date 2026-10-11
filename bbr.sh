cat > /root/bbr.sh <<'EOF'
#!/bin/bash
set -e

echo "===================================="
echo "       TCP BBR Configuration"
echo "===================================="

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi

cat > /etc/sysctl.d/99-bbr.conf <<'CONFIG'
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
CONFIG

echo "[1/3] Applying configuration..."
sysctl --system

echo "[2/3] Checking congestion control..."
sysctl net.ipv4.tcp_congestion_control
sysctl net.core.default_qdisc

echo "[3/3] Checking available algorithms..."
sysctl net.ipv4.tcp_available_congestion_control

if [ "$(sysctl -n net.ipv4.tcp_congestion_control)" = "bbr" ]; then
    echo "SUCCESS: TCP BBR is active."
else
    echo "ERROR: BBR is not active. Check kernel support."
    exit 1
fi

echo "===================================="
EOF

chmod +x /root/bbr.sh
bash /root/bbr.sh
