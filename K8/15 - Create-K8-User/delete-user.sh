#!/bin/bash
# cleanup-user1.sh
# Purpose: Clean up a Kubernetes user created via client certificate (user1)

set -e

USER_NAME="user1"
CONTEXT_NAME="${USER_NAME}-context"
NAMESPACE="prod-ns"
DEFAULT_CONTEXT="kubernetes-admin@kubernetes"  # fallback context

# Optional: paths to user certificate/key files (adjust if different)
USER_KEY="${USER_NAME}.key"
USER_CRT="${USER_NAME}.crt"
USER_CSR="${USER_NAME}.csr"

echo "Step 1: Remove kubeconfig entries for user and context"
kubectl config unset users.${USER_NAME}
kubectl config unset contexts.${CONTEXT_NAME}

#  Reset current-context if it was user1-context
CURRENT=$(kubectl config current-context)
if [ "$CURRENT" == "$CONTEXT_NAME" ]; then
  echo "Current context was ${CONTEXT_NAME}, switching to default context ${DEFAULT_CONTEXT}"
  kubectl config use-context "${DEFAULT_CONTEXT}"
fi

#Make sure kubeconfig is correct and list contexts (will NOT see user1 listed now)
echo "Step 7: listing contexts ..."
kubectl config get-contexts

echo "Step 2: Remove certificate files"
if [ -f "$USER_KEY" ]; then rm -f  "$USER_KEY"; fi
if [ -f "$USER_CRT" ]; then rm -f  "$USER_CRT"; fi
if [ -f "$USER_CSR" ]; then rm -f "$USER_CSR"; fi

echo "User ${USER_NAME} cleanup complete!"

