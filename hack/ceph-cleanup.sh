#!/bin/bash
echo "Cleaning up after rook-ceph"

for i in $(seq 1 5);
do
    echo "Cleaning k-node${i}"
    echo ssh root@192.168.130.5${i} ./ceph-cleanup.sh
    sleep 3
    cat <<EOF
    ################################
    #### REBOOTING k-node${i}      ####
    #### PRESS CTRL+C TO ABORT  ####
    #### IN THE NEXT 10 SECONDS ####
    ################################
EOF
    sleep 10
    ssh root@192.168.130.5${i} reboot now
done
