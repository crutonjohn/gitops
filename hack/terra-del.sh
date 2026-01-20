
kubectl patch -n rook-terra CephFilesystemSubVolumeGroup terra-file-csi -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl patch -n rook-terra CephFilesystem terra-file -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl patch -n rook-terra CephBlockPool terra-block -p '{"metadata":{"finalizers":[]}}' --type=merge


kubectl delete -n rook-terra CephBlockPool terra-block
kubectl delete -n rook-terra CephFilesystem terra-file
kubectl delete -n rook-terra CephFilesystemSubVolumeGroup terra-file-csi
kubectl delete -n rook-terra CephCluster terra


#kubectl patch -n rook-terra CephCluster terra -p '{"metadata":{"finalizers":[]}}' --type=merge
