#!/bin/bash

REPO_URL=$(git config remote.origin.url | sed 's/\.git//g')
REPO_ROOT=$(git rev-parse --show-toplevel)
GHUSER="crutonjohn"

need() {
    which "$1" &>/dev/null || die "Binary '$1' is missing but required"
}

need "kubectl"
need "helm"
need "fluxctl"

message() {
  echo -e "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo "# $1"
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
}

installFlux() {
  message "installing flux"
  # install flux
  helm repo add fluxcd https://charts.fluxcd.io
  kubectl create ns flux
  helm upgrade -i flux --force --install --values "$REPO_ROOT"/cluster/flux/flux/flux-values.yaml --namespace flux fluxcd/flux
  helm upgrade -i helm-operator --force --install --values "$REPO_ROOT"/cluster/flux/helm-operator/flux-helm-operator-values.yaml --namespace flux --set helm.versions=v3 fluxcd/helm-operator

  FLUX_READY=1
  while [ $FLUX_READY != 0 ]; do
    echo "waiting for flux pod to be fully ready..."
    kubectl -n flux wait --for condition=available deployment/flux
    FLUX_READY="$?"
    sleep 5
  done

  # grab output the key
  FLUX_KEY=$(kubectl -n flux logs deployment/flux | grep identity.pub | cut -d '"' -f2)

  message "adding the key to github automatically"
  "$REPO_ROOT"/setup/add-repo-key.sh "$FLUX_KEY"
}

labelStorageHosts() {

  message "labeling storage nodes"

  # hack to label storage nodes
  for NODE in $(kubectl get node -o=custom-columns=NAME:.metadata.name | tail -n 3)
  do kubectl label node $NODE node.longhorn.io/create-default-disk=true
  done
}

labelUPS() {

  message "labeling UPS nodes"

  kubectl label node k-node01.crutonjohn.com ups=tesla
  kubectl label node k-node02.crutonjohn.com ups=edison

}

installFlux
labelStorageHosts
"$REPO_ROOT"/setup/bootstrap-secrets.sh
"$REPO_ROOT"/setup/bootstrap-ingress.sh
"$REPO_ROOT"/setup/bootstrap-pvc.sh

message "all done!"
kubectl get nodes -o=wide
