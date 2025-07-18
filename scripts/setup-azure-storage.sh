#!/bin/bash

# Azure Storage Account and AKS Persistent Volume Setup Script
# This script creates an Azure Storage Account, blob container, and configures AKS persistent volume

set -e

# Variables (modify these as needed)
RESOURCE_GROUP="aks-store-demo-rg"
STORAGE_ACCOUNT_NAME="aksstoredemo$(date +%s)"
CONTAINER_NAME="product-data"
LOCATION="East US"
AKS_CLUSTER_NAME="aks-store-demo-cluster"

echo "=== Azure Storage Account Setup for AKS Store Demo ==="
echo "Resource Group: $RESOURCE_GROUP"
echo "Storage Account: $STORAGE_ACCOUNT_NAME"
echo "Container: $CONTAINER_NAME"
echo "Location: $LOCATION"
echo

# Step 1: Create Resource Group if it doesn't exist
echo "1. Creating Resource Group..."
az group create --name $RESOURCE_GROUP --location "$LOCATION" --output table

# Step 2: Create Storage Account
echo "2. Creating Storage Account..."
az storage account create \
    --name $STORAGE_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --kind StorageV2 \
    --access-tier Hot \
    --output table

# Step 3: Get Storage Account Key
echo "3. Getting Storage Account Key..."
STORAGE_KEY=$(az storage account keys list \
    --resource-group $RESOURCE_GROUP \
    --account-name $STORAGE_ACCOUNT_NAME \
    --query '[0].value' \
    --output tsv)

echo "Storage Account Key obtained: ${STORAGE_KEY:0:10}..."

# Step 4: Create Blob Container
echo "4. Creating Blob Container..."
az storage container create \
    --name $CONTAINER_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --account-key $STORAGE_KEY \
    --public-access off \
    --output table

# Step 5: Create Kubernetes Secret for Storage Account
echo "5. Creating Kubernetes Secret..."
kubectl create secret generic azure-storage-secret \
    --from-literal=azurestorageaccountname=$STORAGE_ACCOUNT_NAME \
    --from-literal=azurestorageaccountkey=$STORAGE_KEY \
    --dry-run=client -o yaml > azure-storage-secret.yaml

echo "✅ Kubernetes secret file created: azure-storage-secret.yaml"

# Step 6: Create sample data file
echo "6. Creating sample data file..."
echo "Product Service Data - $(date)" > sample-product-data.txt
echo "This file demonstrates blob storage integration with AKS" >> sample-product-data.txt

# Upload sample file to blob storage
az storage blob upload \
    --file sample-product-data.txt \
    --name sample-product-data.txt \
    --container-name $CONTAINER_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --account-key $STORAGE_KEY \
    --output table

echo "✅ Sample data uploaded to blob storage"

# Step 7: Output configuration details
echo
echo "=== Configuration Details ==="
echo "Storage Account Name: $STORAGE_ACCOUNT_NAME"
echo "Container Name: $CONTAINER_NAME"
echo "Resource Group: $RESOURCE_GROUP"
echo "Secret File: azure-storage-secret.yaml"
echo
echo "=== Next Steps ==="
echo "1. Apply the secret: kubectl apply -f azure-storage-secret.yaml"
echo "2. Apply the persistent volume: kubectl apply -f azure-blob-pv.yaml"
echo "3. Apply the persistent volume claim: kubectl apply -f azure-blob-pvc.yaml"
echo "4. Deploy the updated product-service with volume mount"
echo

# Save configuration to file
cat > azure-storage-config.txt << EOF
# Azure Storage Configuration
STORAGE_ACCOUNT_NAME=$STORAGE_ACCOUNT_NAME
CONTAINER_NAME=$CONTAINER_NAME
RESOURCE_GROUP=$RESOURCE_GROUP
LOCATION=$LOCATION
EOF

echo "✅ Configuration saved to azure-storage-config.txt"
