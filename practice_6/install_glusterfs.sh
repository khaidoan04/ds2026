#!/bin/bash

echo "=== GlusterFS Installation Script ==="
echo ""

if [ -f /etc/debian_version ]; then
    echo "Detected Debian/Ubuntu system"
    echo "Updating package list..."
    sudo apt-get update
    
    echo "Installing GlusterFS server..."
    sudo apt-get install -y glusterfs-server
    
    echo "Starting GlusterFS daemon..."
    sudo systemctl start glusterd
    sudo systemctl enable glusterd
    
    echo "Checking status..."
    sudo systemctl status glusterd --no-pager
    
elif [ -f /etc/redhat-release ]; then
    echo "Detected CentOS/RHEL system"
    echo "Installing EPEL repository..."
    sudo yum install -y epel-release
    
    echo "Installing GlusterFS server..."
    sudo yum install -y glusterfs-server
    
    echo "Starting GlusterFS daemon..."
    sudo systemctl start glusterd
    sudo systemctl enable glusterd
    
    echo "Checking status..."
    sudo systemctl status glusterd --no-pager
else
    echo "Unsupported Linux distribution"
    exit 1
fi

echo ""
echo "Verifying installation..."
glusterfs --version
glusterd --version

echo ""
echo "=== Firewall Configuration ==="
echo "Configuring firewall rules..."

if command -v ufw &> /dev/null; then
    echo "Using UFW firewall..."
    sudo ufw allow 24007/tcp
    sudo ufw allow 24008/tcp
    sudo ufw allow 49152:49251/tcp
    echo "Firewall rules added"
elif command -v firewall-cmd &> /dev/null; then
    echo "Using firewalld..."
    sudo firewall-cmd --permanent --add-service=glusterfs
    sudo firewall-cmd --reload
    echo "Firewall rules added"
else
    echo "No firewall detected. Please configure manually:"
    echo "  - TCP port 24007"
    echo "  - TCP port 24008"
    echo "  - TCP ports 49152-49251"
fi

echo ""
echo "Installation completed!"

