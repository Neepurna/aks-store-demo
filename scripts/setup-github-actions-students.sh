#!/bin/bash

# Alternative GitHub Actions Setup for Students/Limited Permissions
# This script helps you set up GitHub Actions with limited Azure permissions

echo "🎓 GitHub Actions Setup for Azure Students Account"
echo "================================================="
echo ""

# Your current Azure information
SUBSCRIPTION_ID="2f102bb6-9366-4011-bd8c-7c072753c204"
TENANT_ID="b5dc206c-17fd-4b06-8bc8-24f0bb650229"

echo "📋 Your Azure Account Information:"
echo "- Subscription ID: $SUBSCRIPTION_ID"
echo "- Tenant ID: $TENANT_ID"
echo "- Account Type: Azure for Students"
echo ""

echo "🏗️ Available Resources:"
echo "- Resource Group (Dev): lab1-resourcegroup"
echo "- AKS Cluster (Dev): lab01cluster"
echo "- Resource Group (Staging): aks-lab"
echo "- AKS Cluster (Staging): aks-lab-cluster"
echo ""

echo "⚠️  SERVICE PRINCIPAL CREATION ISSUE:"
echo "Your Azure for Students account doesn't have permission to create service principals."
echo ""

echo "🔧 SOLUTIONS:"
echo ""
echo "Option 1: Contact Azure Administrator"
echo "----------------------------------------"
echo "Ask your instructor/admin to create service principals for you with these commands:"
echo ""
echo "# For Development Environment:"
echo "az ad sp create-for-rbac --name \"aks-store-demo-dev-sp\" \\"
echo "  --role contributor \\"
echo "  --scopes \"/subscriptions/$SUBSCRIPTION_ID/resourceGroups/lab1-resourcegroup\" \\"
echo "  --sdk-auth"
echo ""
echo "# For Staging Environment:"
echo "az ad sp create-for-rbac --name \"aks-store-demo-staging-sp\" \\"
echo "  --role contributor \\"
echo "  --scopes \"/subscriptions/$SUBSCRIPTION_ID/resourceGroups/aks-lab\" \\"
echo "  --sdk-auth"
echo ""

echo "Option 2: Use Federated Identity (OpenID Connect)"
echo "------------------------------------------------"
echo "This is more secure and doesn't require service principal secrets."
echo "Your admin needs to configure this in Azure Active Directory."
echo ""

echo "Option 3: Development/Testing Workaround"
echo "----------------------------------------"
echo "For testing purposes only, you can use a simplified approach:"
echo ""

# Check if user wants to continue with testing approach
read -p "Do you want to set up a development-only configuration? (y/n): " SETUP_DEV

if [ "$SETUP_DEV" == "y" ]; then
    echo ""
    echo "🚀 Setting up development configuration..."
    
    # Test AKS access
    echo "Testing AKS access..."
    if az aks get-credentials --resource-group lab1-resourcegroup --name lab01cluster --overwrite-existing; then
        echo "✅ Successfully connected to lab01cluster"
    else
        echo "❌ Failed to connect to AKS cluster"
        exit 1
    fi
    
    # Test kubectl access
    if kubectl get nodes > /dev/null 2>&1; then
        echo "✅ kubectl is working with AKS cluster"
    else
        echo "❌ kubectl access failed"
        exit 1
    fi
    
    echo ""
    echo "📝 Manual GitHub Secrets Setup:"
    echo "Since we can't create service principals, you'll need to:"
    echo ""
    echo "1. Go to your GitHub repository settings"
    echo "2. Create these environments: dev, staging"
    echo "3. For each environment, add these secrets:"
    echo ""
    echo "   For DEV environment:"
    echo "   - AZURE_RESOURCE_GROUP: lab1-resourcegroup"
    echo "   - AZURE_CLUSTER_NAME: lab01cluster"
    echo "   - AZURE_CREDENTIALS: [Ask your instructor for service principal]"
    echo ""
    echo "   For STAGING environment:"
    echo "   - AZURE_RESOURCE_GROUP: aks-lab"
    echo "   - AZURE_CLUSTER_NAME: aks-lab-cluster"
    echo "   - AZURE_CREDENTIALS: [Ask your instructor for service principal]"
    echo ""
    
    echo "💡 AZURE_CREDENTIALS format (what your instructor should provide):"
    echo "{"
    echo "  \"clientId\": \"your-client-id\","
    echo "  \"clientSecret\": \"your-client-secret\","
    echo "  \"subscriptionId\": \"$SUBSCRIPTION_ID\","
    echo "  \"tenantId\": \"$TENANT_ID\""
    echo "}"
    echo ""
    
    echo "4. Once you have the service principal from your instructor:"
    echo "   - Copy the JSON output"
    echo "   - Paste it as the value for AZURE_CREDENTIALS secret"
    echo ""
    
    echo "🎉 Setup guidance completed!"
    echo ""
    echo "📚 What to tell your instructor:"
    echo "\"I need service principals created for GitHub Actions CI/CD pipeline"
    echo "to deploy to AKS clusters. Please run the commands shown above and"
    echo "provide me with the JSON output to use as GitHub secrets.\""
    
else
    echo "Setup cancelled. Please contact your instructor for service principal creation."
fi

echo ""
echo "🔗 Useful Links:"
echo "- GitHub Environments: https://github.com/Neepurna/aks-store-demo/settings/environments"
echo "- Azure Service Principals: https://learn.microsoft.com/azure/active-directory/develop/app-objects-and-service-principals"
echo "- GitHub Actions with Azure: https://learn.microsoft.com/azure/developer/github/connect-from-azure"
