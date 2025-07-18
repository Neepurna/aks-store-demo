#!/bin/bash

# AKS Store Demo - GitHub Actions Setup Script
# This script helps you set up the required GitHub secrets for the CI/CD pipeline

set -e

echo "🚀 AKS Store Demo - GitHub Actions Setup"
echo "========================================"
echo ""

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed. Please install it first:"
    echo "   https://github.com/cli/cli#installation"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Please authenticate with GitHub CLI first:"
    echo "   gh auth login"
    exit 1
fi

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first:"
    echo "   https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

echo "✅ Prerequisites check passed!"
echo ""

# Get current repository
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
echo "📦 Repository: $REPO"
echo ""

# Function to set GitHub secret
set_github_secret() {
    local secret_name=$1
    local secret_value=$2
    local environment=$3
    
    if [ -n "$environment" ]; then
        echo "🔐 Setting secret: $secret_name (for environment: $environment)"
        gh secret set "$secret_name" --body "$secret_value" --env "$environment"
    else
        echo "🔐 Setting secret: $secret_name (repository level)"
        gh secret set "$secret_name" --body "$secret_value"
    fi
}

# Azure Service Principal Creation
echo "🔑 Creating Azure Service Principal..."
echo "Please provide your Azure subscription details:"
read -p "Azure Subscription ID: " SUBSCRIPTION_ID
read -p "Azure Resource Group (dev): " RESOURCE_GROUP_DEV
read -p "Azure AKS Cluster Name (dev): " CLUSTER_NAME_DEV

# Create service principal for dev environment
echo "Creating service principal for dev environment..."
SP_DEV=$(az ad sp create-for-rbac --name "aks-store-demo-dev-sp" \
    --role contributor \
    --scopes "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_DEV" \
    --sdk-auth)

# Set dev environment secrets
set_github_secret "AZURE_CREDENTIALS" "$SP_DEV" "dev"
set_github_secret "AZURE_RESOURCE_GROUP" "$RESOURCE_GROUP_DEV" "dev"
set_github_secret "AZURE_CLUSTER_NAME" "$CLUSTER_NAME_DEV" "dev"

echo "✅ Dev environment secrets configured!"

# Ask for staging environment
read -p "Do you want to configure staging environment? (y/n): " SETUP_STAGING

if [ "$SETUP_STAGING" == "y" ]; then
    read -p "Azure Resource Group (staging): " RESOURCE_GROUP_STAGING
    read -p "Azure AKS Cluster Name (staging): " CLUSTER_NAME_STAGING
    
    # Create service principal for staging environment
    echo "Creating service principal for staging environment..."
    SP_STAGING=$(az ad sp create-for-rbac --name "aks-store-demo-staging-sp" \
        --role contributor \
        --scopes "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_STAGING" \
        --sdk-auth)
    
    # Set staging environment secrets
    set_github_secret "AZURE_CREDENTIALS_STAGING" "$SP_STAGING" "staging"
    set_github_secret "AZURE_RESOURCE_GROUP_STAGING" "$RESOURCE_GROUP_STAGING" "staging"
    set_github_secret "AZURE_CLUSTER_NAME_STAGING" "$CLUSTER_NAME_STAGING" "staging"
    
    echo "✅ Staging environment secrets configured!"
fi

# Ask for production environment
read -p "Do you want to configure production environment? (y/n): " SETUP_PROD

if [ "$SETUP_PROD" == "y" ]; then
    read -p "Azure Resource Group (production): " RESOURCE_GROUP_PROD
    read -p "Azure AKS Cluster Name (production): " CLUSTER_NAME_PROD
    
    # Create service principal for production environment
    echo "Creating service principal for production environment..."
    SP_PROD=$(az ad sp create-for-rbac --name "aks-store-demo-prod-sp" \
        --role contributor \
        --scopes "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_PROD" \
        --sdk-auth)
    
    # Set production environment secrets
    set_github_secret "AZURE_CREDENTIALS_PROD" "$SP_PROD" "prod"
    set_github_secret "AZURE_RESOURCE_GROUP_PROD" "$RESOURCE_GROUP_PROD" "prod"
    set_github_secret "AZURE_CLUSTER_NAME_PROD" "$CLUSTER_NAME_PROD" "prod"
    
    echo "✅ Production environment secrets configured!"
fi

echo ""
echo "🎉 GitHub Actions setup completed!"
echo ""
echo "📋 Summary:"
echo "- Repository: $REPO"
echo "- Dev environment configured: ✅"
echo "- Staging environment configured: $([ "$SETUP_STAGING" == "y" ] && echo "✅" || echo "❌")"
echo "- Production environment configured: $([ "$SETUP_PROD" == "y" ] && echo "✅" || echo "❌")"
echo ""
echo "🚀 Next steps:"
echo "1. Create GitHub environments (dev, staging, prod) in your repository settings"
echo "2. Configure environment protection rules as needed"
echo "3. Push changes to trigger the CI/CD pipeline"
echo "4. Monitor the deployment in the Actions tab"
echo ""
echo "🔗 Useful links:"
echo "- GitHub Actions: https://github.com/$REPO/actions"
echo "- Repository Settings: https://github.com/$REPO/settings"
echo "- Environment Settings: https://github.com/$REPO/settings/environments"
