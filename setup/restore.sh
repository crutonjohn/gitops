#!/bin/bash

REPO_ROOT=$(git rev-parse --show-toplevel)

kubectl apply -f $REPO_ROOT/master.key
