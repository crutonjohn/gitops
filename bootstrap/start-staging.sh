#!/usr/bin/env bash

set -eou pipefail

export GITHUB_USER=crutonjohn
export GITHUB_TOKEN=$(cat ~/.secret/github_access_token)
export GITHUB_REPO=gitops
export CLUSTER="${CLUSTER:-staging}"
export KUBECONFIG=~/.kube/staging.config
export REPO_ROOT=$(git rev-parse --show-toplevel)

# KUBECONFIG=~/projects/install/ansible/playbooks/output/k8s-config.yaml:~/.kube/config kubectl config view --flatten > ~/.kube/config.tmp && \
#   mv ~/.kube/config.tmp ~/.kube/config

flux >/dev/null || \
  ( echo "flux needs to be installed - https://toolkit.fluxcd.io/get-started/#install-the-toolkit-cli" && exit 1 )

# Untaint master nodes in pprd since there are only 3
[[ ! $(kubectl taint nodes --all node-role.kubernetes.io/master-) ]] && echo "Masters untainted"

if [[ -f .secrets/git-crypt/k8s-staging-sealed-secret-private-key.yaml ]]; then
  echo "Applying existing sealed-secret key"
  kubectl apply -f .secrets/git-crypt/k8s-staging-sealed-secret-private-key.yaml
fi

# Check the cluster meets the fluxv2 prerequisites
flux check --pre || \
  ( echo "Prerequisites were not satisfied" && exit 1 )

echo "Applying cluster: ${CLUSTER}"
flux bootstrap github \
  --owner="${GITHUB_USER}" \
  --repository="${GITHUB_REPO}" \
  --path=k8s/clusters/"${CLUSTER}" \
  --branch=main \
  --network-policy=false \
  --personal

"$REPO_ROOT"/bootstrap/secrets.sh
"$REPO_ROOT"/bootstrap/ingress.sh
"$REPO_ROOT"/bootstrap/pvc.sh