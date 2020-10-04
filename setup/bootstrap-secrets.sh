#!/bin/bash

REPO_ROOT=$(git rev-parse --show-toplevel)

MANIFEST_ROOT="${REPO_ROOT}/cluster"

GENERATED_SECRETS="${MANIFEST_ROOT}/z-generated_secrets.yaml"

need() {
    which "$1" &>/dev/null || die "Binary '$1' is missing but required"
}

need "kubeseal"
need "kubectl"
need "sed"
need "envsubst"
need "yq"

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

ksealhelm() {
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  # Get the path and basename of the txt file
  # e.g. "deployments/default/pihole/pihole-helm-values"
  secret="$(dirname "$@")/$(basename -s .txt "$@")"
  echo "Secret: ${secret}"
  # Get the filename without extension
  # e.g. "pihole-helm-values"
  secret_name=$(basename "${secret}")
  echo "Secret Name: ${secret_name}"
  # Extract the Kubernetes namespace from the secret path
  # e.g. default
  namespace="$(echo "${secret}" | awk -F /cluster/ '{ print $2; }' | awk -F / '{ print $1; }')"
  echo "Namespace: ${namespace}"
  # Create secret and put it in the applications deployment folder
  # e.g. "deployments/default/pihole/pihole-helm-values.yaml"
  envsubst < "$@" | tee values.yaml \
    | \
  kubectl -n "${namespace}" create secret generic "${secret_name}" \
    --from-file=values.yaml --dry-run=client -o json \
    | \
  kubeseal --format=yaml --cert="$PUB_CERT" \
    > "${secret}.yml"
  # Clean up temp file
  rm values.yaml
}

ksealraw() {
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  secret="$(dirname "$1")/$(basename -s .txt "$1")"
  echo "Secret: ${secret}"
  secret_name=$(basename "${secret}")
  echo "Secret Name: ${secret_name}"
  echo "Data Value: $2"
  namespace="$(echo "${secret}" | awk -F /cluster/ '{ print $2; }' | awk -F / '{ print $1; }')"
  echo "Namespace: ${namespace}"
  envsubst < "$1" | tee file.raw \
    | \
  kubectl -n "${namespace}" create secret generic "${secret_name}" \
    --from-file=$2=file.raw --dry-run=client -o json \
    | \
  kubeseal --format=yaml --cert="$PUB_CERT" \
    >> "${GENERATED_SECRETS}"
  # Clean up temp file
  rm file.raw
  echo "---" >> "${GENERATED_SECRETS}"
}

generateSecrets(){
  . "$REPO_ROOT"/setup/.env

  bigMessage "installing manual secrets and objects"

  message "ensure that kubeseal is available"
  
  SEALED_SECRETS_READY=1
  while [ $SEALED_SECRETS_READY != 0 ]; do
    echo "waiting on sealed-secrets to be ready..."
    # this is a hack to check for the namespace
    kubectl -n kube-system wait --for condition=Available deployment/sealed-secrets > /dev/null 2>&1
    SEALED_SECRETS_READY="$?"
    sleep 5
  done
  # get public cert from sealed secrets
  kubeseal --fetch-cert --controller-name=sealed-secrets --controller-namespace=kube-system > "$REPO_ROOT"/pub-cert.pem
  PUB_CERT="$REPO_ROOT/pub-cert.pem"

  bigMessage "Creating Kube Literal Secrets"

  {
    echo "# -~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-"
    echo "# -~-~ NOW ENTERING THE SECRET ZONE ~-~-"
    echo "# -~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-"
    echo "---"
  } > "${GENERATED_SECRETS}"

  ## Generic Secrets


  # Longhorn System Minio
  message "Minio (Longhorn Backup) Secret"
  
  kubectl create secret generic minio-secrets \
    --from-literal=accesskey="${LONGHORN_MINIO_ACCESSKEY}" \
    --from-literal=secretkey="${LONGHORN_MINIO_SECRETKEY}" \
    --namespace longhorn-system --dry-run=client -o json \
    | \
  kubeseal --format=yaml --cert="${PUB_CERT}" \
    >> "${GENERATED_SECRETS}"
  echo "---" >> "${GENERATED_SECRETS}"

  kubectl create secret generic longhorn-backup-secret \
    --from-literal=AWS_ACCESS_KEY_ID="${LONGHORN_MINIO_ACCESSKEY}" \
    --from-literal=AWS_SECRET_ACCESS_KEY="${LONGHORN_MINIO_SECRETKEY}" \
    --from-literal=AWS_ENDPOINTS="${LONGHORN_MINIO_INTERNAL_DNS}" \
    --namespace longhorn-system --dry-run=client -o json \
    | \
  kubeseal --format=yaml --cert="${PUB_CERT}" \
    >> "${GENERATED_SECRETS}"
  echo "---" >> "${GENERATED_SECRETS}"

  message "Bitwarden Secret"

  # bitwarden
  kubectl create secret generic bitwarden-env \
    --from-literal=DOMAIN="${BITWARDEN_DOMAIN}" \
    --from-literal=SIGNUPS_ALLOWED="${BITWARDEN_SIGNUPS_ALLOWED}" \
    --from-literal=INVITATIONS_ALLOWED="${BITWARDEN_INVITATIONS_ALLOWED}" \
    --from-literal=SERVER_ADMIN_EMAIL="${BITWARDEN_SERVER_ADMIN_EMAIL}" \
    --from-literal=SMTP_FROM="${SMTP_FROM}" \
    --from-literal=SMTP_HOST="${SMTP_HOST}" \
    --from-literal=SMTP_PASSWORD="${SMTP_PASSWORD}" \
    --from-literal=SMTP_PORT="${BITWARDEN_SMTP_PORT}" \
    --from-literal=SMTP_EXPLICIT_TLS="${BITWARDEN_SMTP_EXPLICIT_TLS}" \
    --from-literal=SMTP_USERNAME="${SMTP_USERNAME}" \
    --from-literal=SMTP_AUTH_MECHANISM="${BITWARDEN_SMTP_AUTH_MECHANISM}" \
    --from-literal=ADMIN_TOKEN="${BITWARDEN_ADMIN_TOKEN}" \
    --namespace bitwarden --dry-run=client -o json \
    | \
  kubeseal --format=yaml --cert="${PUB_CERT}" \
    >> "${GENERATED_SECRETS}"
  echo "---" >> "${GENERATED_SECRETS}"

  message "Nextcloud Secrets"

  # nextcloud database stuff
  kubectl create secret generic nextcloud-db-secrets \
    --from-literal=POSTGRES_PASSWORD="${NEXTCLOUD_DB_PASSWORD}" \
    --from-literal=POSTGRES_USER="${NEXTCLOUD_DB_USER}" \
    --from-literal=POSTGRES_HOST="${NEXTCLOUD_DB_HOST}" \
    --from-literal=POSTGRES_DB="${NEXTCLOUD_DB_NAME}" \
    --namespace nextcloud --dry-run=client -o json \
    | \
  kubeseal --format=yaml --cert="${PUB_CERT}" \
    >> "${GENERATED_SECRETS}"
  echo "---" >> "${GENERATED_SECRETS}"

  # nextcloud nginx stuff
  kubectl create secret generic nextcloud-nginx-secrets \
    --from-literal=VIRTUAL_HOST="${NEXTCLOUD_VIRTUAL_HOST}" \
    --from-literal=VIRTUAL_PORT="${NEXTCLOUD_VIRTUAL_PORT}" \
    --namespace nextcloud --dry-run=client -o json \
    | \
  kubeseal --format=yaml --cert="${PUB_CERT}" \
    >> "${GENERATED_SECRETS}"
  echo "---" >> "${GENERATED_SECRETS}"

  message "UPS Secrets"

  # Tesla UPS secrets
  kubectl create secret generic ups-tesla-env \
    --from-literal=UPS_NAME="tesla" \
    --from-literal=UPS_DESC="tesla-CP1500AVRLCD" \
    --from-literal=UPS_DRIVER="usbhid-ups" \
    --from-literal=UPS_PORT="/dev/ups" \
    --from-literal=API_USER="${UPS_API_USER}" \
    --from-literal=API_PASSWORD="${UPS_API_PASSWORD}" \
    --namespace monitoring --dry-run=client -o json \
    | \
  kubeseal --format=yaml --cert="${PUB_CERT}" \
    >> "${GENERATED_SECRETS}"
  echo "---" >> "${GENERATED_SECRETS}"

  # Edison UPS secrets
  kubectl create secret generic ups-edison-env \
    --from-literal=UPS_NAME="edison" \
    --from-literal=UPS_DESC="edison-CP1500AVRLCD" \
    --from-literal=UPS_DRIVER="usbhid-ups" \
    --from-literal=UPS_PORT="/dev/ups" \
    --from-literal=API_USER="${UPS_API_USER}" \
    --from-literal=API_PASSWORD="${UPS_API_PASSWORD}" \
    --namespace monitoring --dry-run=client -o json \
    | \
  kubeseal --format=yaml --cert="${PUB_CERT}" \
    >> "${GENERATED_SECRETS}"
  echo "---" >> "${GENERATED_SECRETS}"

  bigMessage "Apply All Generated Certs"

  kubectl apply -f ${GENERATED_SECRETS}

  bigMessage "Creating Helm Operator Secrets"

  ksealhelm "${MANIFEST_ROOT}/monitoring/botkube/botkube.txt"
  ksealhelm "${MANIFEST_ROOT}/auth-system/oauth-proxy/oauth-proxy.txt"
  ksealhelm "${MANIFEST_ROOT}/monitoring/prometheus-operator/prometheus-operator-helm-values.txt"
  ksealhelm "${MANIFEST_ROOT}/games/minecraft/minecraft-helm-values.txt"

  bigMessage "Creating Raw Kubernetes Secrets"

  ksealraw "${MANIFEST_ROOT}/network-system/aws-external-dns/aws-external-dns.txt" "credentials"

}

export KUBECONFIG="$HOME/.kube/config"
generateSecrets

bigMessage "all done!"
