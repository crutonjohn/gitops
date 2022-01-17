#!/bin/bash
echo "Cleaning up after rook-ceph"

for i in $(seq 1 5);
do
    echo "Cleaning k-node${i}"
    ssh root@192.168.130.5${i} ./ceph-cleanup.sh
    sleep 3
done
