#!/bin/bash

VOLUME_NAME="gv0"
REPLICA_COUNT=2
NODES=("node1" "node2" "node3" "node4")
BRICK_BASE="/data/brick"

echo "=== GlusterFS Volume Setup Script ==="
echo "Volume name: $VOLUME_NAME"
echo "Replica count: $REPLICA_COUNT"
echo ""

echo "Step 1: Creating trusted pool..."
for node in "${NODES[@]:1}"; do
    echo "Probing $node..."
    gluster peer probe "$node"
done

echo ""
echo "Checking peer status..."
gluster peer status

echo ""
echo "Step 2: Preparing bricks on each node..."
echo "Please run the following on each node:"
echo "  sudo mkdir -p /data/brick1"
echo "  sudo mkdir -p /data/brick2"

read -p "Press Enter after bricks are created on all nodes..."

echo ""
echo "Step 3: Creating volume..."
BRICKS=""
for node in "${NODES[@]}"; do
    BRICKS="$BRICKS ${node}:${BRICK_BASE}1"
    BRICKS="$BRICKS ${node}:${BRICK_BASE}2"
done

gluster volume create "$VOLUME_NAME" replica "$REPLICA_COUNT" $BRICKS force

echo ""
echo "Step 4: Starting volume..."
gluster volume start "$VOLUME_NAME"

echo ""
echo "Step 5: Checking volume status..."
gluster volume status "$VOLUME_NAME"
gluster volume info "$VOLUME_NAME"

echo ""
echo "Volume setup completed!"
echo ""
echo "To mount the volume on clients:"
echo "  sudo mkdir -p /mnt/glusterfs"
echo "  sudo mount -t glusterfs ${NODES[0]}:/$VOLUME_NAME /mnt/glusterfs"

