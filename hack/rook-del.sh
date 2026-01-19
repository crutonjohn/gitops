
kubectl patch -n rook-terra CephObjectStore terra-objectstore -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl patch -n rook-terra CephFilesystemSubVolumeGroup terra-filesystem-csi -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl patch -n rook-terra CephFilesystem terra-filesystem -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl patch -n rook-terra CephBlockPool terra-blockpool -p '{"metadata":{"finalizers":[]}}' --type=merge


kubectl delete -n rook-terra CephBlockPool terra-blockpool
kubectl delete -n rook-terra CephFilesystem terra-filesystem
kubectl delete -n rook-terra CephFilesystemSubVolumeGroup terra-filesystem-csi
kubectl delete -n rook-terra CephObjectStore terra-objectstore
kubectl delete -n rook-terra CephCluster terra


#kubectl patch -n rook-terra CephCluster terra -p '{"metadata":{"finalizers":[]}}' --type=merge
