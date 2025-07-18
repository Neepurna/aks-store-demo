#!/bin/bash

# Deploy Azure Blob Storage integration with AKS
# This script deploys the persistent volume and updated product-service

set -e

echo "=== Deploying Azure Blob Storage Integration with AKS ==="
echo

# Check if Azure CLI is available
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install it first."
    exit 1
fi

# Check if kustomize is available
if ! command -v kustomize &> /dev/null; then
    echo "Installing kustomize..."
    curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
    sudo mv kustomize /usr/local/bin/
fi

echo "✅ Required tools are available"
echo

# Create namespace if it doesn't exist
echo "1. Creating namespace..."
kubectl create namespace aks-store-demo --dry-run=client -o yaml | kubectl apply -f -

# Build and apply the kustomize configuration
echo "2. Building kustomize configuration..."
cd kustomize/base
kustomize build . > /tmp/azure-blob-deployment.yaml

echo "3. Applying Kubernetes resources..."
kubectl apply -f /tmp/azure-blob-deployment.yaml

echo "4. Waiting for resources to be ready..."
sleep 10

echo "5. Checking deployment status..."
kubectl get pv,pvc,storageclass -n aks-store-demo | grep -E "(azure-blob|NAME)"
kubectl get pods -n aks-store-demo -l app=product-service

echo "6. Describing the product-service deployment..."
kubectl describe deployment product-service -n aks-store-demo

echo "7. Checking volume mounts in the pod..."
POD_NAME=$(kubectl get pods -n aks-store-demo -l app=product-service -o jsonpath='{.items[0].metadata.name}')
if [ -n "$POD_NAME" ]; then
    echo "Pod Name: $POD_NAME"
    kubectl describe pod $POD_NAME -n aks-store-demo | grep -A 10 -B 5 "Volumes:"
    
    echo "8. Testing volume mount..."
    kubectl exec -n aks-store-demo $POD_NAME -- ls -la /mnt/azure-blob || echo "⚠️  Volume not yet mounted"
else
    echo "⚠️  No product-service pod found"
fi

echo
echo "✅ Deployment completed!"
echo
echo "=== Summary ==="
echo "- Storage Class: azure-blob-storage"
echo "- Persistent Volume: azure-blob-pv"
echo "- Persistent Volume Claim: azure-blob-pvc"
echo "- Volume Mount: /mnt/azure-blob in product-service"
echo
echo "=== Verification Commands ==="
echo "kubectl get pv,pvc -n aks-store-demo"
echo "kubectl describe deployment product-service -n aks-store-demo"
echo "kubectl exec -n aks-store-demo <pod-name> -- ls -la /mnt/azure-blob"
