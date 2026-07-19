#!/bin/sh

# generate the admin token needed to login into K8 dashboard (paste)
kubectl -n kubernetes-dashboard create token admin-user

# on top of page, filter out by namkespace since default is selected

