# AKS Store Demo - Kustomize CI/CD Pipeline

This document describes the GitHub Actions CI/CD pipeline setup for deploying the AKS Store Demo application using Kustomize.

## 🏗️ Pipeline Architecture

The CI/CD pipeline consists of the following components:

### 1. Main Deployment Pipeline (`deploy-kustomize.yaml`)
- **Trigger**: Push to main branch, PR to main branch, or manual workflow dispatch
- **Jobs**:
  - `validate-kustomize`: Validates Kustomize configurations
  - `build-and-push-images`: Builds and pushes container images to GHCR
  - `deploy-dev`: Deploys to development environment
  - `deploy-staging`: Deploys to staging environment (manual trigger)

### 2. Cleanup Pipeline (`cleanup-kustomize.yaml`)
- **Trigger**: Manual workflow dispatch
- **Purpose**: Clean up resources from specified environment

## 🚀 Getting Started

### Prerequisites

1. **Azure Resources**:
   - Azure Kubernetes Service (AKS) cluster(s)
   - Azure Container Registry (optional - using GHCR)
   - Proper RBAC permissions

2. **GitHub Setup**:
   - Forked repository
   - GitHub CLI installed
   - Azure CLI installed

3. **Local Tools**:
   - kubectl
   - kustomize
   - Docker (for local testing)

### Setup Instructions

1. **Run the Setup Script**:
   ```bash
   ./scripts/setup-github-actions.sh
   ```

2. **Configure GitHub Environments**:
   - Go to your repository settings
   - Create environments: `dev`, `staging`, `prod`
   - Configure protection rules as needed

3. **Required GitHub Secrets**:
   
   For each environment, you'll need:
   - `AZURE_CREDENTIALS`: Azure service principal credentials
   - `AZURE_RESOURCE_GROUP`: Azure resource group name
   - `AZURE_CLUSTER_NAME`: AKS cluster name

   Example Azure credentials format:
   ```json
   {
     "clientId": "your-client-id",
     "clientSecret": "your-client-secret",
     "subscriptionId": "your-subscription-id",
     "tenantId": "your-tenant-id"
   }
   ```

## 📁 Directory Structure

```
kustomize/
├── base/                    # Base Kubernetes manifests
│   ├── kustomization.yaml
│   ├── store-front.yaml
│   ├── store-admin.yaml
│   └── ...
└── overlays/               # Environment-specific overlays
    ├── dev/                # Development environment
    │   └── kustomization.yaml
    ├── staging/            # Staging environment
    │   ├── kustomization.yaml
    │   └── resources-patch.yaml
    └── prod/               # Production environment
        ├── kustomization.yaml
        ├── resources-patch.yaml
        └── hpa-patch.yaml
```

## 🔧 Environment Configuration

### Development Environment
- **Namespace**: `aks-store-demo`
- **Replicas**: 1 (default)
- **Resources**: Minimal resource requests/limits
- **Auto-deploy**: On every push to main

### Staging Environment
- **Namespace**: `aks-store-demo-staging`
- **Replicas**: 2 for main services
- **Resources**: Moderate resource allocation
- **Deploy**: Manual trigger via workflow dispatch

### Production Environment
- **Namespace**: `aks-store-demo-prod`
- **Replicas**: 3 for main services
- **Resources**: Higher resource allocation
- **HPA**: Horizontal Pod Autoscaler enabled
- **Deploy**: Manual trigger (implement additional approvals)

## 🔄 Deployment Workflow

### Automated Deployment (Development)
1. Push code to main branch
2. Pipeline validates Kustomize configurations
3. Builds and pushes container images
4. Deploys to development environment
5. Verifies deployment status

### Manual Deployment (Staging/Production)
1. Navigate to GitHub Actions
2. Select "Deploy AKS Store Demo with Kustomize"
3. Click "Run workflow"
4. Select target environment
5. Monitor deployment progress

## 🛠️ Customization

### Adding New Services
1. Add service manifests to `kustomize/base/`
2. Update `kustomize/base/kustomization.yaml`
3. Add service to build matrix in workflow
4. Update environment-specific patches if needed

### Environment-Specific Configuration
- **Resources**: Modify `resources-patch.yaml` in overlay
- **Replicas**: Update `replicas` section in `kustomization.yaml`
- **Labels**: Add/modify `commonLabels` in `kustomization.yaml`

### Image Management
The pipeline automatically:
- Builds images with SHA-based tags
- Updates image references in Kustomize
- Pushes to GitHub Container Registry (GHCR)

## 🔍 Monitoring and Troubleshooting

### Checking Deployment Status
```bash
# Connect to your AKS cluster
az aks get-credentials --resource-group <rg> --name <cluster>

# Check pod status
kubectl get pods -n aks-store-demo

# Check service status
kubectl get svc -n aks-store-demo

# Check deployment status
kubectl get deployments -n aks-store-demo
```

### Common Issues

1. **Image Pull Errors**: Ensure GHCR access is configured
2. **Resource Limits**: Check cluster resource availability
3. **RBAC Issues**: Verify service principal permissions
4. **Network Policies**: Ensure pod-to-pod communication

### Logs and Debugging
```bash
# Check pod logs
kubectl logs -n aks-store-demo deployment/store-front

# Describe problematic pods
kubectl describe pod -n aks-store-demo <pod-name>

# Check events
kubectl get events -n aks-store-demo --sort-by=.metadata.creationTimestamp
```

## 🧪 Testing

### Local Testing
```bash
# Test kustomize build
cd kustomize/overlays/dev
kustomize build .

# Validate against cluster
kustomize build . | kubectl apply --dry-run=client -f -
```

### Integration Testing
The pipeline includes:
- Kustomize validation
- Dry-run deployment checks
- Rollout status verification
- Basic health checks

## 🔐 Security Considerations

1. **Service Principals**: Use least-privilege access
2. **Secrets Management**: Store sensitive data in GitHub Secrets
3. **Network Security**: Configure network policies
4. **Image Security**: Scan images for vulnerabilities
5. **Environment Protection**: Use branch protection rules

## 📊 Monitoring and Observability

### Azure Monitor Integration
The application includes monitoring capabilities:
- Application Insights for APM
- Azure Monitor for cluster metrics
- Log Analytics for centralized logging

### Prometheus/Grafana (Optional)
For additional monitoring:
```bash
# Install monitoring stack
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/bundle.yaml
```

## 🔄 Cleanup

### Manual Cleanup
Use the cleanup workflow:
1. Go to GitHub Actions
2. Select "Cleanup AKS Store Demo"
3. Choose environment
4. Type "confirm" to proceed

### Automated Cleanup
Consider implementing:
- Scheduled cleanup for dev environments
- Resource quotas and limits
- Automated testing environments

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test locally
4. Submit a pull request
5. Ensure all checks pass

## 📚 Additional Resources

- [Kustomize Documentation](https://kustomize.io/)
- [Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Container Security Best Practices](https://docs.microsoft.com/en-us/azure/aks/concepts-security)

## 🆘 Support

For issues and questions:
1. Check the [troubleshooting section](#monitoring-and-troubleshooting)
2. Review GitHub Actions logs
3. Check Azure Monitor for cluster issues
4. Create an issue in the repository
