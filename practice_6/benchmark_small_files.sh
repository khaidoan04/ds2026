#!/bin/bash

NUM_FILES=1000
FILE_SIZE=1024
MOUNT_POINT=/mnt/glusterfs
RESULTS_FILE="small_files_results.txt"

if [ ! -d "$MOUNT_POINT" ]; then
    echo "Error: Mount point $MOUNT_POINT does not exist"
    exit 1
fi

echo "=== Small Files Benchmark ==="
echo "Number of files: $NUM_FILES"
echo "File size: $FILE_SIZE bytes"
echo "Mount point: $MOUNT_POINT"
echo ""

echo "Creating $NUM_FILES small files..."
START_TIME=$(date +%s.%N)
for i in $(seq 1 $NUM_FILES); do
    dd if=/dev/urandom of="$MOUNT_POINT/small_file_$i" bs=$FILE_SIZE count=1 2>/dev/null
done
END_TIME=$(date +%s.%N)
WRITE_TIME=$(echo "$END_TIME - $START_TIME" | bc)
echo "Write completed in ${WRITE_TIME} seconds"
echo ""

echo "Testing read performance..."
START_TIME=$(date +%s.%N)
for i in $(seq 1 $NUM_FILES); do
    cat "$MOUNT_POINT/small_file_$i" > /dev/null
done
END_TIME=$(date +%s.%N)
READ_TIME=$(echo "$END_TIME - $START_TIME" | bc)
ACCESSES_PER_SEC=$(echo "scale=2; $NUM_FILES / $READ_TIME" | bc)

echo "Read completed in ${READ_TIME} seconds"
echo "Accesses per second: $ACCESSES_PER_SEC"
echo ""

echo "Cleaning up..."
rm -f "$MOUNT_POINT"/small_file_*

echo "Results saved to $RESULTS_FILE"
echo "Files: $NUM_FILES, Size: $FILE_SIZE bytes, Accesses/sec: $ACCESSES_PER_SEC" > "$RESULTS_FILE"

