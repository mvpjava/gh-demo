#!/bin/bash
# Temporary workaround for the Mountpoint S3 CSI Driver v2.7.0 RBAC issue.
# The controller performs leader election using Kubernetes Lease objects.
# The official ClusterRole lacks permissions for coordination.k8s.io/leases, causing mount failures.
# This patch grants the required Lease permissions so the controller can become leader and process S3 mount requests.
set -e

echo "Backing up current ClusterRole..."
kubectl get clusterrole s3-csi-driver-controller-cluster-role -o yaml > s3-csi-driver-controller-cluster-role-backup.yaml

echo "Granting Lease permissions..."

kubectl patch clusterrole s3-csi-driver-controller-cluster-role --type='json' -p='[
  {
    "op": "add",
    "path": "/rules/-",
    "value": {
      "apiGroups": ["coordination.k8s.io"],
      "resources": ["leases"],
      "verbs": ["get","list","watch","create","update","patch"]
    }
  }
]'

echo
echo "Verifying RBAC..."
kubectl auth can-i \
  get leases.coordination.k8s.io \
  --as=system:serviceaccount:kube-system:s3-csi-driver-controller-sa \
  -n kube-system

echo
echo "Restarting controller..."
kubectl rollout restart deployment s3-csi-controller -n kube-system

echo
echo "Waiting for rollout..."
kubectl rollout status deployment/s3-csi-controller -n kube-system

echo
echo "Controller logs:"
kubectl logs -n kube-system deploy/s3-csi-controller --tail=50

# To restore original RBAC
#kubectl apply -f s3-csi-driver-controller-cluster-role-backup.yaml
# or re-install the original manifest
#kubectl apply -k "https://github.com/awslabs/mountpoint-s3-csi-driver/deploy/kubernetes/overlays/stable"

# Verify patch is still present
# kubectl get clusterrole s3-csi-driver-controller-cluster-role -o yamlo
# - apiGroups:
#  - coordination.k8s.io
#  resources:
#  - leases
#  verbs:
#  - get
#  - list
#  - watch
#  - create
#  - update
#  - patch
