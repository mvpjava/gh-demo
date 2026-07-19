#!/bin/sh

kubectl apply -f wordpress-configmap.yaml

# Verification
kubectl describe configmap wordpress-config
