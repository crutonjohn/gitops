#!/bin/bash
# See https://justyn.io/til/migrate-kubernetes-pvc-to-another-pvc/ for details

set -exu

src=$1
dst=$2

echo "Copying $1 to $2"

echo "please cancel this script if this doesn't look right"

echo "sleeping to allow interrupt"

sleep 7

echo "proceeding with copy job"

echo "Creating job yaml"
cat > migrate-job-$1.yaml << EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: migrate-pv-$src
spec:
  template:
    spec:
      containers:
      - name: migrate
        image: debian
        command: [ "/bin/bash", "-c" ]
        args:
          -
            apt-get update && apt-get install -y rsync &&
            ls -lah /src_vol /dst_vol &&
            df -h &&
            rsync -avPS --delete /src_vol/ /dst_vol/ &&
            ls -lah /dst_vol/ &&
            du -shxc /src_vol/ /dst_vol/
        volumeMounts:
        - mountPath: /src_vol
          name: src
          readOnly: true
        - mountPath: /dst_vol
          name: dst
      nodeSelector:
        kubernetes.io/arch: "amd64"
      restartPolicy: Never
      volumes:
      - name: src
        persistentVolumeClaim:
          claimName: $src
      - name: dst
        persistentVolumeClaim:
          claimName: $dst
  backoffLimit: 1
EOF

kubectl create -f migrate-job.yaml
kubectl get jobs -o wide
kubectl get pods | grep migrate
