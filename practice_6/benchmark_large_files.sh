#!/bin/bash

FILE_SIZE_MB=1024
NUM_FILES=5
MOUNT_POINT=/mnt/glusterfs
RESULTS_FILE="large_files_results.txt"

if [ ! -d "$MOUNT_POINT" ]; then
    echo "Error: Mount point $MOUNT_POINT does not exist"
    exit 1
fi

echo "=== Large Files Benchmark ==="
echo "Number of files: $NUM_FILES"
echo "File size: ${FILE_SIZE_MB}MB"
echo "Mount point: $MOUNT_POINT"
echo ""

echo "Creating large test files..."
for i in $(seq 1 $NUM_FILES); do
    echo "Creating large_file_$i (${FILE_SIZE_MB}MB)..."
    dd if=/dev/urandom of="$MOUNT_POINT/large_file_$i" bs=1M count=$FILE_SIZE_MB 2>/dev/null
done
echo ""

echo "Testing read speed..."
TOTAL_SPEED=0
for i in $(seq 1 $NUM_FILES); do
    echo "Reading large_file_$i..."
    START_TIME=$(date +%s.%N)
    dd if="$MOUNT_POINT/large_file_$i" of=/dev/null bs=1M 2>&1 | tail -1
    END_TIME=$(date +%s.%N)
    ELAPSED=$(echo "$END_TIME - $START_TIME" | bc)
    SPEED=$(echo "scale=2; $FILE_SIZE_MB / $ELAPSED" | bc)
    echo "Speed: ${SPEED} MB/s"
    TOTAL_SPEED=$(echo "$TOTAL_SPEED + $SPEED" | bc)
done

AVG_SPEED=$(echo "scale=2; $TOTAL_SPEED / $NUM_FILES" | bc)
echo ""
echo "Average read speed: ${AVG_SPEED} MB/s"

echo "Cleaning up..."
rm -f "$MOUNT_POINT"/large_file_*

echo "Results saved to $RESULTS_FILE"
echo "Files: $NUM_FILES, Size: ${FILE_SIZE_MB}MB each, Avg Speed: ${AVG_SPEED} MB/s" > "$RESULTS_FILE"

