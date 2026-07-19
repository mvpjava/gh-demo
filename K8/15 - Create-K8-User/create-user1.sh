#!/bin/bash
# create-k8s-user.sh
# Purpose: Create a Kubernetes user "user1" with certificate that will be 
# then defined in $HOME/.kube/config where
# Each user requires a name and token. The token is often an X.509
# certificate that is the user’s ID. If it is, it has to be signed by the cluster’s CA or a CA trusted by the cluster

set -e
#set -x

USER_NAME="user1"
NAMESPACE="prod-ns"
CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
KUBECONFIG="$HOME/.kube/config"

# Paths to cluster CA certs (adjust if your cluster uses different path)
CA_CERT="/etc/kubernetes/pki/ca.crt"
CA_KEY="/etc/kubernetes/pki/ca.key"

# Output files
USER_KEY="${USER_NAME}.key"
USER_CSR="${USER_NAME}.csr"
USER_CERT="${USER_NAME}.crt"

echo "Step 1: Create namespace if it doesn't exist"
kubectl get ns ${NAMESPACE} >/dev/null 2>&1 || kubectl create namespace ${NAMESPACE}

echo "Step 2: Generate private key for user"
openssl genrsa -out ${USER_KEY} 2048

echo "Step 3: Create certificate signing request (CSR) for ${USER_NAME}"
openssl req -new -key ${USER_KEY} -out ${USER_CSR} -subj "/CN=${USER_NAME}/O=dev"

echo "Step 4: Sign CSR with Kubernetes CA"
sudo openssl x509 -req -in ${USER_CSR} -CA ${CA_CERT} -CAkey ${CA_KEY} \
  -CAcreateserial -out ${USER_CERT} -days 365
  
# Now you have:
#  - user1.crt → user certificate
#  - user1.key → user private key

echo "Step 5: Add user to kubeconfig"
kubectl config set-credentials ${USER_NAME} \
  --client-certificate=${USER_CERT} \
  --client-key=${USER_KEY} \
  --embed-certs=true

echo "Step 6: Create context for user"
kubectl config set-context ${USER_NAME}-context \
  --cluster=${CLUSTER_NAME} \
  --namespace=${NAMESPACE} \
  --user=${USER_NAME}




