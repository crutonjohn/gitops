# Install Flux

## SOPS

- Make sure that your `.sops.yml` is valid.
- Pre-create the `flux-system` namespace:
```
kubectl create namespace flux-system --dry-run=client -o yaml | kubectl apply -f -
```
- Apply the sops GPG key secret to the cluster:
  - For me, I need to specify my AWS profile as this is encrypted with my AWS KMS key.
```
AWS_PROFILE=personal sops -d sops-secret.enc.yaml | kubectl apply -f -
```

## Flux Bootstrap

- Firstly we need to set our `GITHUB_TOKEN` variable. To do this one needs to be generated in Github. See [these flux docs](https://fluxcd.io/docs/installation/#github-and-github-enterprise) for more info.
  - I typically set this for my session, but it can also be set solely for the command.
  - This is for `fish` shell btw

```
set -gx GITHUB_TOKEN "ghp_......"
```

- Then just bootstrap.
  - This example is for bootstrapping a `production` cluster, but you can bootstrap different environments, implying that the code exists to do so.

```
flux bootstrap github \
  --components=source-controller,kustomize-controller,helm-controller,notification-controller \
  --path=clusters/env/production \
  --version=latest \
  --owner=crutonjohn \
  --repository=gitops
```
