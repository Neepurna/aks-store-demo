## Azure Configuration Information

### 🔑 **Account Details:**
- **Subscription ID**: `2f102bb6-9366-4011-bd8c-7c072753c204`
- **Tenant ID**: `b5dc206c-17fd-4b06-8bc8-24f0bb650229`
- **Subscription**: Azure for Students
- **User**: 101586698@georgebrown.ca

### 🏗️ **Available Resources:**

#### Resource Groups:
- `lab1-resourcegroup` (canadacentral) - **RECOMMENDED for dev**
- `aks-lab` (eastus2) - **RECOMMENDED for staging**
- `aks-store-cluster_group` (canadacentral)

#### AKS Clusters:
- `lab01cluster` (canadacentral, lab1-resourcegroup) - ✅ **WORKING**
- `aks-lab-cluster` (eastus2, aks-lab) - ✅ **WORKING**  
- `aks-store-demo` (canadacentral, lab1-resourcegroup) - ❌ **FAILED**

### 🚀 **Recommended Environment Setup:**

#### Development Environment:
- **AZURE_RESOURCE_GROUP**: `lab1-resourcegroup`
- **AZURE_CLUSTER_NAME**: `lab01cluster`
- **Location**: canadacentral

#### Staging Environment:
- **AZURE_RESOURCE_GROUP**: `aks-lab`
- **AZURE_CLUSTER_NAME**: `aks-lab-cluster`
- **Location**: eastus2

## 🔧 **Next Steps for Service Principal:**

Since you have limited permissions, you have several options:

### Option 1: Request Admin Access
Contact your Azure administrator to create service principals for you with these commands:

```bash
# For Dev Environment
az ad sp create-for-rbac --name "aks-store-demo-dev-sp" \
  --role contributor \
  --scopes "/subscriptions/2f102bb6-9366-4011-bd8c-7c072753c204/resourceGroups/lab1-resourcegroup" \
  --sdk-auth

# For Staging Environment  
az ad sp create-for-rbac --name "aks-store-demo-staging-sp" \
  --role contributor \
  --scopes "/subscriptions/2f102bb6-9366-4011-bd8c-7c072753c204/resourceGroups/aks-lab" \
  --sdk-auth
```

### Option 2: Use User-Assigned Managed Identity
Create a user-assigned managed identity and grant it access to your AKS cluster.

### Option 3: Use Azure CLI with Personal Access Token
For development/testing, you can use a simplified approach with your current credentials.

## 🏃‍♂️ **Quick Start (Development Only):**

For now, you can test the pipeline by using your current credentials, but this is NOT recommended for production.

1. Get your current Azure credentials:
   ```bash
   az account get-access-token --query accessToken --output tsv
   ```

2. Use the cluster credentials directly:
   ```bash
   az aks get-credentials --resource-group lab1-resourcegroup --name lab01cluster
   ```

## 🎯 **GitHub Secrets Configuration:**

Based on your setup, here's what you need to configure:

### For Dev Environment:
```
AZURE_RESOURCE_GROUP = lab1-resourcegroup
AZURE_CLUSTER_NAME = lab01cluster
AZURE_CREDENTIALS = [SERVICE_PRINCIPAL_JSON_FROM_ADMIN]
```

### For Staging Environment:
```
AZURE_RESOURCE_GROUP = aks-lab
AZURE_CLUSTER_NAME = aks-lab-cluster  
AZURE_CREDENTIALS = [SERVICE_PRINCIPAL_JSON_FROM_ADMIN]
```
