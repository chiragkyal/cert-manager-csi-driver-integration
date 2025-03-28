# check the CertificateRequest object - created automatically
kubectl get crs -A

# check the certificates present on the pod
echo "============================"
kubectl -n sandbox exec -it workload -- \
    ls /var/run/secrets/certificate
echo "============================"
kubectl -n sandbox exec -it workload -- \
    openssl x509 -noout -text -in /var/run/secrets/certificate/tls.crt
