#!/bin/bash

# xRef: https://cert-manager.io/docs/configuration/vault/#c-authenticating-with-kubernetes-service-accounts
# https://developer.hashicorp.com/vault/docs/auth/kubernetes

# enable authentication
kubectl -n vault exec vault-0 -- \
    vault auth enable kubernetes

kubectl -n vault exec vault-0 -- \
    vault write auth/kubernetes/config \
    kubernetes_host="https://kubernetes.default.svc.cluster.local"

# Configure vault to accept service account token from the cluster, and
# use the service account token to authenticate to vault and to request certificates from vault.
# It is recommended to use a different Vault role each per Issuer or ClusterIssuer.
# The audience allows you to restrict the Vault role to a single Issuer or ClusterIssuer.
# Create Vault role
# `policies=pki-policy` -- should match from the previous step
kubectl -n vault exec vault-0 -- \
    vault write auth/kubernetes/role/vault-issuer-role \
    bound_service_account_names=vault-issuer-sa \
    bound_service_account_namespaces=sandbox \
    audience="vault://sandbox/vault-issuer" \
    policies=pki-policy \
    ttl=1m
