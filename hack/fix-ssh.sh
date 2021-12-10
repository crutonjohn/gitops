#!/usr/bin/env bash

set -e -u -o pipefail

# NB: The Ed25519-format key does not work with Flux.
for secret_name in flux-system ; do
  kubectl --namespace=flux-system \
          patch secret "${secret_name}" \
          --patch='
stringData:
  known_hosts: >
    github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg='
done

kubectl --namespace=flux-system rollout restart deployment source-controller
kubectl --namespace=flux-system rollout status deployment/source-controller --watch
