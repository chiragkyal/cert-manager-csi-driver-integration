#!/bin/bash

# xRef: https://developer.hashicorp.com/vault/docs/secrets/pki/setup
# https://developer.hashicorp.com/vault/api-docs/secret/pki

# Enable the PKI secrets engine
kubectl -n vault exec pods/vault-0 -- \
    vault secrets enable pki

# Configure a CA certificate and private key.
# Vault can accept an existing key pair, or it can generate its own self-signed root.
# Generate a Root CA to issue certificates
kubectl -n vault exec pods/vault-0 -- \
    vault write pki/root/generate/internal \
    common_name="My Example Root CA" \
    ttl=8760h
# This creates a self-signed root CA within Vault

# Configure a role that maps a name in Vault to a procedure for generating a certificate.
# When users or machines generate credentials, they are generated against this role:
# This creates a role named example-dot-com that allows issuing certificates
# for the example.com domain, its subdomains, and SPIFFE URI SAN with a maximum TTL of 72h.
# See https://developer.hashicorp.com/vault/api-docs/secret/pki for different config options
kubectl -n vault exec pods/vault-0 -- \
    vault write pki/roles/example-dot-com \
    allowed_domains=example.com \
    allowed_uri_sans="spiffe://example.com/*" \
    allow_subdomains=true \
    require_cn=false \
    max_ttl=72h

# Create vault policy to access the signed certificate
# Path is the Vault path that will be used for signing. Note that the path must use the sign endpoint.
# This `path` will be used while creating the issuer and the `policy name`
#    will be used while creating vault role (in the next step)
kubectl -n vault exec -i --tty=false pods/vault-0 -- vault policy write pki-policy - <<EOF
path "pki/sign/example-dot-com" {
  capabilities = ["read", "list", "create", "update"]
}
EOF

# Extract Root CA from vault
# We will use it to build trust
kubectl -n vault exec pods/vault-0 -- \
    vault read -field=certificate pki/cert/ca >ca.crt
