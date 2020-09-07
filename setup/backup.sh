#!/bin/bash

REPO_ROOT=$(git rev-parse --show-toplevel)

kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml > $REPO_ROOT/master.key
