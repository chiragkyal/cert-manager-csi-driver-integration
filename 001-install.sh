#!/bin/bash

# Create a kind cluster
kind create cluster --name cm-csi-driver

# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.0/cert-manager.yaml

# wait for cert-manager pods to be running
kubectl wait --for=condition=Ready --timeout=120s pods --all -n cert-manager

# Install cert-manager-csi-driver
helm repo add jetstack https://charts.jetstack.io --force-update
helm upgrade cert-manager-csi-driver jetstack/cert-manager-csi-driver \
    --install \
    --namespace cert-manager \
    --wait

# wait for cert-manager-csi-driver pods to be running
kubectl wait --for=condition=Ready --timeout=120s pods --all -n cert-manager

# Install a vault instance in the cluster
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm install vault hashicorp/vault \
    --namespace=vault \
    --create-namespace \
    -f _001-vault-values.yaml

# wait for vault pods to be running
kubectl wait --for=condition=Ready --timeout=120s pods --all -n vault

kubectl -n vault get pods
