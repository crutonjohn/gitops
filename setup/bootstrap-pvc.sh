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

generatePVC() {
  
  bigMessage "Creating PVCs"

  message "Waiting for Longhorn"

  CSI_ATTACHER_READY=1
  while [ $CSI_ATTACHER_READY != 0 ]; do
    message "waiting for Longhorn CSI Attacher to be fully ready..."
    kubectl -n longhorn-system wait --for condition=Available deployment/csi-attacher > /dev/null 2>&1
    CSI_ATTACHER_READY="$?"
    sleep 5
  done

  CSI_PROVISIONER_READY=1
  while [ $CSI_PROVISIONER_READY != 0 ]; do
    message "waiting for Longhorn CSI Provisioner to be fully ready..."
    kubectl -n longhorn-system wait --for condition=Available deployment/csi-provisioner > /dev/null 2>&1
    CSI_PROVISIONER_READY="$?"
    sleep 5
  done

  CSI_RESIZER_READY=1
  while [ $CSI_RESIZER_READY != 0 ]; do
    message "waiting for Longhorn CSI Resizer to be fully ready..."
    kubectl -n longhorn-system wait --for condition=Available deployment/csi-resizer > /dev/null 2>&1
    CSI_RESIZER_READY="$?"
    sleep 5
  done

  DRIVER_READY=1
  while [ $DRIVER_READY != 0 ]; do
    message "waiting for Longhorn Driver to be fully ready..."
    kubectl -n longhorn-system wait --for condition=Available deployment/longhorn-driver-deployer > /dev/null 2>&1
    DRIVER_READY="$?"
    sleep 5
  done

  UI_READY=1
  while [ $UI_READY != 0 ]; do
    message "waiting for Longhorn UI to be fully ready..."
    kubectl -n longhorn-system wait --for condition=Available deployment/longhorn-ui > /dev/null 2>&1
    UI_READY="$?"
    sleep 5
  done

  message "Longhorn PVCs"
  # apply PVCs with env subs

  for i in $(find $MANIFEST_ROOT -type f -name "pvc.txt")
  do
    kapply "$i"
  done
  
}

export KUBECONFIG="$HOME/.kube/config"
generatePVC

bigMessage "all done!"