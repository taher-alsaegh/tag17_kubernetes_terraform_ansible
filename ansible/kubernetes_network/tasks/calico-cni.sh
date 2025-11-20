#!/bin/bash

KUBECONFIG_PATH="/root/.kube/config"

kubectl --kubeconfig=$KUBECONFIG_PATH create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/tigera-operator.yaml

sleep 1m

kubectl --kubeconfig=$KUBECONFIG_PATH create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/custom-resources.yaml
