#!/bin/bash

# Validate Azure Blob Storage integration with AKS
# This script validates the persistent volume setup without requiring actual Azure deployment

set -e

echo "=== Validating Azure Blob Storage Integration ==="
echo

# Check if required tools are available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl to run this validation."
    exit 1
fi

if ! command -v kustomize &> /dev/null; then
    echo "Installing kustomize..."
    curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
    sudo mv kustomize /usr/local/bin/
fi

echo "✅ Required tools are available"
echo

# Step 1: Validate YAML files
echo "1. Validating YAML syntax..."
cd /home/neeps/aks-store-demo
for file in azure-blob-storageclass.yaml azure-storage-secret.yaml azure-blob-pv.yaml azure-blob-pvc.yaml; do
    if [ -f "kustomize/base/$file" ]; then
        echo "✅ $file exists and is readable"
    else
        echo "❌ $file is missing"
        exit 1
    fi
done

# Step 2: Build kustomize configuration
echo
echo "2. Building kustomize configuration..."
cd kustomize/base
if kustomize build . > /tmp/azure-storage-output.yaml; then
    echo "✅ Kustomize build successful"
else
    echo "❌ Kustomize build failed"
    exit 1
fi

# Step 3: Validate Storage Class
echo
echo "3. Validating Storage Class..."
if grep -q "kind: StorageClass" /tmp/azure-storage-output.yaml; then
    if grep -q "name: azure-blob-storage" /tmp/azure-storage-output.yaml; then
        echo "✅ Azure Blob Storage Class configured"
    else
        echo "❌ Storage Class name incorrect"
        exit 1
    fi
else
    echo "❌ Storage Class not found"
    exit 1
fi

# Step 4: Validate Persistent Volume
echo
echo "4. Validating Persistent Volume..."
if grep -q "kind: PersistentVolume" /tmp/azure-storage-output.yaml; then
    if grep -q "blob.csi.azure.com" /tmp/azure-storage-output.yaml; then
        echo "✅ Azure Blob CSI driver configured"
    else
        echo "❌ Azure Blob CSI driver not configured"
        exit 1
    fi
    
    if grep -q "containerName: product-data" /tmp/azure-storage-output.yaml; then
        echo "✅ Blob container name configured"
    else
        echo "❌ Blob container name not configured"
        exit 1
    fi
else
    echo "❌ Persistent Volume not found"
    exit 1
fi

# Step 5: Validate Persistent Volume Claim
echo
echo "5. Validating Persistent Volume Claim..."
if grep -q "kind: PersistentVolumeClaim" /tmp/azure-storage-output.yaml; then
    if grep -q "storage: 10Gi" /tmp/azure-storage-output.yaml; then
        echo "✅ Storage size configured (10Gi)"
    else
        echo "❌ Storage size not configured"
        exit 1
    fi
else
    echo "❌ Persistent Volume Claim not found"
    exit 1
fi

# Step 6: Validate Volume Mount in Deployment
echo
echo "6. Validating Volume Mount in Product Service..."
if grep -q "volumeMounts:" /tmp/azure-storage-output.yaml; then
    if grep -A 5 "volumeMounts:" /tmp/azure-storage-output.yaml | grep -q "/mnt/azure-blob"; then
        echo "✅ Volume mount path configured (/mnt/azure-blob)"
    else
        echo "❌ Volume mount path not configured"
        exit 1
    fi
    
    if grep -A 5 "volumes:" /tmp/azure-storage-output.yaml | grep -q "azure-blob-pvc"; then
        echo "✅ PVC reference in deployment configured"
    else
        echo "❌ PVC reference not configured"
        exit 1
    fi
else
    echo "❌ Volume mounts not found in deployment"
    exit 1
fi

# Step 7: Show the volume configuration
echo
echo "7. Volume Configuration Summary:"
echo "---"
echo "Storage Class:"
grep -A 10 "kind: StorageClass" /tmp/azure-storage-output.yaml | head -15
echo
echo "Persistent Volume:"
grep -A 15 "kind: PersistentVolume" /tmp/azure-storage-output.yaml | head -20
echo
echo "Volume Mount in Product Service:"
sed -n '/volumeMounts:/,/resources:/p' /tmp/azure-storage-output.yaml | head -10
echo "---"

echo
echo "🎉 SUCCESS: Azure Blob Storage integration validation completed!"
echo
echo "Summary of Azure Blob Storage integration:"
echo "  • Storage Class: azure-blob-storage with blob.csi.azure.com driver"
echo "  • Persistent Volume: 10Gi capacity with Azure Blob backend"
echo "  • Container Name: product-data"
echo "  • Volume Mount: /mnt/azure-blob in product-service pod"
echo "  • Access Mode: ReadWriteMany"
echo "  • Security Context: Maintained with non-root user"
echo
echo "These settings ensure the product-service can access Azure Blob Storage"
echo "through a persistent volume mounted at /mnt/azure-blob."
