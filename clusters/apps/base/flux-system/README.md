# Starting Cluster

By default, the source-controller watches for sources only in the flux-system namespace, this way cluster admins can prevent untrusted sources from being registered by users.


## Production Cluster (amd64)

```bash
export GITHUB_TOKEN="<PAT>"
```

```bash
flux bootstrap github \
  --components=source-controller,kustomize-controller,helm-controller,notification-controller \
  --path=clusters \
  --version=latest \
  --owner=crutonjohn \
  --repository=gitops \
  --arch=amd64
```

```bash
flux create source git gitops \
  --url=https://github.com/crutonjohn/gitops \
  --branch=main \
  --interval=30s \
  --export > ./gitops.yaml
```

```bash
flux install \
  --components=source-controller,kustomize-controller,helm-controller,notification-controller \
  --namespace=flux-system \
  --arch=amd64
```

## Staging Cluster (arm64)

```bash
export GITHUB_TOKEN="<PAT>"
```

```bash
flux bootstrap github \
  --components=source-controller,kustomize-controller,helm-controller,notification-controller \
  --path=clusters \
  --version=latest \
  --owner=crutonjohn \
  --repository=gitops \
  --arch=arm64
```

```bash
flux create source git gitops \
  --url=https://github.com/crutonjohn/gitops \
  --branch=fluxv2-init \
  --interval=30s \
  --export > ./gitops.yaml
```

```bash
flux install \
  --components=source-controller,kustomize-controller,helm-controller,notification-controller \
  --namespace=flux-system \
  --arch=arm64
```