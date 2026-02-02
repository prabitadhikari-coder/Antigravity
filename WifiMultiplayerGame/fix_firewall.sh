#!/bin/bash
echo "Attempting to open Port 5555 for Buckshot LAN..."

# Check for UFW (Uncomplicated Firewall) - Standard on Ubuntu/Debian
if command -v ufw >/dev/null; then
    echo "Detected UFW. Adding rule..."
    sudo ufw allow 5555/tcp
    sudo ufw reload
    echo "[SUCCESS] UFW Rule added for Port 5555."

# Check for FirewallD - Standard on Fedora/CentOS
elif command -v firewall-cmd >/dev/null; then
    echo "Detected FirewallD. Adding rule..."
    sudo firewall-cmd --zone=public --add-port=5555/tcp --permanent
    sudo firewall-cmd --reload
    echo "[SUCCESS] FirewallD Rule added for Port 5555."

# Fallback to IPTables
elif command -v iptables >/dev/null; then
    echo "Detected IPTables. Adding rule..."
    sudo iptables -A INPUT -p tcp --dport 5555 -j ACCEPT
    echo "[SUCCESS] IPTables rule added (Runtime only)."
else
    echo "[ERROR] Could not detect a supported firewall manager (ufw, firewall-cmd, iptables)."
fi
echo "Done."
