
kubectl patch -n rook-codex CephFilesystemSubVolumeGroup codex-file-csi -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl patch -n rook-codex CephFilesystem codex-file -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl patch -n rook-codex CephBlockPool codex-block -p '{"metadata":{"finalizers":[]}}' --type=merge


kubectl delete -n rook-codex CephBlockPool codex-block
kubectl delete -n rook-codex CephFilesystem codex-file
kubectl delete -n rook-codex CephFilesystemSubVolumeGroup codex-file-csi
kubectl delete -n rook-codex CephCluster codex


#kubectl patch -n rook-terra CephCluster terra -p '{"metadata":{"finalizers":[]}}' --type=merge
