#!/bin/sh

# Encode the password
echo -n 'password' | base64
# Output (Example): TXlTdHJvbmdEQlBhc3MxMjMh
# TODO !!! make sure you paster encoded passord in yaml

kubectl apply -f mysql-secret.yaml

# Verification (optional, but shows the secret is there):
kubectl get secret mysql-secret
