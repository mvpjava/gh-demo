#!/bin/sh

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

sleep 10

#Check all READY/RUNNING
kubectl get all -n kubernetes-dashboard

kubectl apply -f dashboard.yaml

kubectl get svc -n kubernetes-dashboard

# create admin-user ServiceAccount, so Kubernetes cannot generate a token for it.
kubectl apply -f dashboard-admin-user.yaml

# Verify the ServiceAccount Exists
kubectl get sa -n kubernetes-dashboard

# Execute script to grt token to be able to login into dashboard in browser
./02-create-admin-token.sh

# Goto https://public_mamnager_ip:$NODE_PORT_NUM
# Select "Token" option and paste the token
# Accept self-signed security certificate
# Change namespace in browser admin console (on top)

