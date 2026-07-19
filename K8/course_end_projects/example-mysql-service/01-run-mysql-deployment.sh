#!/bin/sh

kubectl apply -f mysql-deployment.yaml

wait 10

# Verify the Pod is Running:
kubectl get pods -l app=mysql -o wide

#kubectl describe pod mysql-deployment-5ff9754579-j96b8

# Verify the Service is Running (Note the ClusterIP):
kubectl get svc mysql-service

kubectl logs deployment/mysql-deployment
