#!/bin/bash

REPO_ROOT=$(git rev-parse --show-toplevel)

MANIFEST_ROOT="${REPO_ROOT}/cluster"

GENERATED_SECRETS="${MANIFEST_ROOT}/z-generated_secrets.yaml"

need() {
    which "$1" &>/dev/null || die "Binary '$1' is missing but required"
}

need "kubectl"
need "sed"
need "envsubst"

# Work-arounds for MacOS
if [ "$(uname)" == "Darwin" ]; then
  # brew install gnu-sed
  need "gsed"
  # use sed as alias to gsed
  export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
  # Source secrets.env
  set -a
  . "${REPO_ROOT}/setup/.env"
  set +a
else
  . "${REPO_ROOT}/setup/.env"
fi

bigMessage() {
  echo -e "\n########################################################################"
  echo "# $1"
  echo "########################################################################"
}

message() {
  echo -e "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo "# $1"
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
}

kapply() {
  if output=$(envsubst < "$@"); then
    printf '%s' "$output" | kubectl apply -f -
  fi
}

generateIngressRoutes() {
  
  bigMessage "Creating Ingress Routes"

  message "Waiting for Traefik"

  TRAEFIK_READY=1
  while [ $TRAEFIK_READY != 0 ]; do
    message "waiting for Traefik to be fully ready..."
    kubectl -n network-system wait --for condition=Available deployment/traefik > /dev/null 2>&1
    TRAEFIK_READY="$?"
    sleep 5
  done

  message "Traefik Ingresses"
  # apply ingressroutes with env subs

  for i in "$REPO_ROOT"/cluster/*/ingress.txt
  do
    kapply "$i"
  done
  
}

export EXTERNAL_IP=$(curl checkip.amazonaws.com)
export KUBECONFIG="$HOME/.kube/config"
generateIngressRoutes

bigMessage "all done!"