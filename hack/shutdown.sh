#!/bin/bash
echo "Shutting down workers"

for i in $(seq 1 5);
do
    echo "Shutting Down k-node${i}"
    sleep 1
    ssh root@192.168.130.5${i} shutdown now
done

sleep 5

for i in $(seq 1 3);
do
    echo "Shutting Down k-master0${i}"
    sleep 1
    ssh root@192.168.130.3${i} shutdown now
done
