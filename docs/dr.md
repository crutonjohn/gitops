# Disaster Recovery

Currently my DR plan is backed by [kasten k10](https://docs.kasten.io/latest/index.html), but I am also running [velero](https://velero.io/docs) just because.

This doc is respectfully borrowed from [Toboshii's Restore Process](https://toboshii.github.io/home-cluster/restore/), and slightly adapted.

## Flux

- First, create the `flux-system` namespace:
```
kubectl create namespace flux-system --dry-run=client -o yaml | kubectl apply -f -
```

- Create the flux gpg secret:
```
AWS_PROFILE=personal sops -d sops-secret.enc.yaml | kubectl apply -f -
```

- Create the flux deployment:
```
kubectl apply --kustomize=./clusters/env/production/flux-system
```

## K10 PVC Restore

- Create secret by using the DR token provided by your previously working K10 installation.
  - Mine is stored in my cluster-secrets.yaml
```
sops -d clusters/env/production/config/cluster-secrets.yaml
```

```
kubectl create secret generic k10-dr-secret \
    --namespace kasten-io \
    --from-literal key=<passphrase>
```

- Verify that the K10 application is deployed with flux:
```
kubectl get po -n kasten-io
```

- Verify that the backup storage location is deployed:
```
kubectl get pvc k10-backup -n kasten-io
```

- Navigate to the webui and verify the backup location

- Install the DR restore job with a manual helm install:
  -
```
helm install k10-restore kasten/k10restore --namespace=kasten-io \
    --set sourceClusterID=<source-clusterID> \
    --set profile.name=<location-profile-name>
```

- Upon completion of the DR Restore job, go to the `Applications` card, select `Removed` under the `Filter by status` drop-down menu.
  - Click restore under the application and select a restore point to recover from.
