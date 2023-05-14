#!/bin/bash
# See https://justyn.io/til/migrate-kubernetes-pvc-to-another-pvc/ for details

set -exu

pvc=$1

echo "Debugging $1"

echo "please cancel this script if this doesn't look right"

echo "sleeping to allow interrupt"

sleep 7

echo "proceeding with copy job"

echo "Creating job yaml"
cat > debug-pvc-$1.yaml << EOF
kind: Pod
apiVersion: v1
metadata:
  name: volume-debugger
spec:
  volumes:
    - name: volume-to-debug
      persistentVolumeClaim:
       claimName: $pvc
  containers:
    - name: debugger
      image: busybox
      command: ['sleep', '3600']
      volumeMounts:
        - mountPath: "/data"
          name: volume-to-debug
  securityContext:
    fsGroup: 7843
    runAsGroup: 7843
    runAsUser: 7843
EOF

kubectl create -f debug-pvc-$1.yaml
kubectl get po -o wide | grep volume-debugger
kubectl get po -o name | grep volume-debugger
kubectl get pods | grep migrate
