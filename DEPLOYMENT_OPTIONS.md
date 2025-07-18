## 🚀 **SIMPLEST SOLUTION - No Service Principal Needed!**

Since you have trouble creating service principals, here are **3 practical approaches** you can use:

---

## **🎯 Option 1: Manual Deployment (Recommended for Students)**

You can deploy manually from your local machine where you're already authenticated:

### **Step 1: Test the Pipeline Locally**
```bash
# Test kustomize validation
make kustomize-validate

# Deploy to your AKS cluster
make kustomize-deploy-dev

# Check status
make kustomize-status

# If you want to clean up
make kustomize-cleanup-dev
```

### **Step 2: Use GitHub Actions for CI Only**
- Use GitHub Actions to build and push images
- Use local deployment for actual AKS deployment
- This is perfect for learning and development

---

## **🎯 Option 2: Contact Your Course Instructor/Administrator**

If you're taking this as part of a course at George Brown College:

### **Who to Contact:**
- **Your course instructor/professor**
- **IT department** at George Brown College
- **Lab administrator** who manages the Azure subscription

### **What to Ask:**
*"Hi, I'm working on a GitHub Actions CI/CD pipeline for Kubernetes deployment. I need help creating Azure service principals for automated deployment. Can you help me run these commands?"*

**Commands to share with them:**
```bash
# For Development Environment:
az ad sp create-for-rbac --name "aks-store-demo-dev-sp" \
  --role contributor \
  --scopes "/subscriptions/2f102bb6-9366-4011-bd8c-7c072753c204/resourceGroups/lab1-resourcegroup" \
  --sdk-auth

# For Staging Environment:
az ad sp create-for-rbac --name "aks-store-demo-staging-sp" \
  --role contributor \
  --scopes "/subscriptions/2f102bb6-9366-4011-bd8c-7c072753c204/resourceGroups/aks-lab" \
  --sdk-auth
```

---

## **🎯 Option 3: Use GitHub Codespaces (Advanced)**

If you have access to GitHub Codespaces, you can run the deployment from there:

### **Step 1: Open in Codespaces**
1. Go to your GitHub repository
2. Click the green "Code" button
3. Select "Codespaces" tab
4. Click "Create codespace on main"

### **Step 2: Setup in Codespaces**
```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login to Azure
az login

# Setup AKS credentials
az aks get-credentials --resource-group lab1-resourcegroup --name lab01cluster

# Deploy using make
make kustomize-deploy-dev
```

---

## **🎯 Option 4: GitHub Actions with Personal Access Token (Simplest)**

You can use a GitHub Actions workflow that uses your existing Azure credentials:

### **Step 1: Create a Simple Workflow**
I've created a workflow file: `.github/workflows/deploy-self-hosted.yaml`

### **Step 2: Set up GitHub Environment**
1. Go to: `https://github.com/Neepurna/aks-store-demo/settings/environments`
2. Create environment: `dev`
3. **No secrets needed** if you use self-hosted runner

### **Step 3: Set up Self-Hosted Runner (on your machine)**
1. Go to: `https://github.com/Neepurna/aks-store-demo/settings/actions/runners`
2. Click "New self-hosted runner"
3. Follow the instructions to install the runner on your machine
4. The runner will use your existing Azure credentials

---

## **🎯 RECOMMENDED FOR YOU: Option 1 (Manual)**

Since you already have:
- ✅ Azure CLI working
- ✅ kubectl working  
- ✅ AKS cluster access
- ✅ GitHub repository

**Just use the manual approach:**

```bash
# 1. Build and test locally
make kustomize-validate

# 2. Deploy to AKS
make kustomize-deploy-dev

# 3. Check deployment
kubectl get pods -n aks-store-demo
kubectl get svc -n aks-store-demo

# 4. Access your application
kubectl port-forward svc/store-front 8080:80 -n aks-store-demo
# Then open http://localhost:8080 in your browser
```

**This approach:**
- ✅ Works immediately
- ✅ No service principal needed
- ✅ Perfect for learning
- ✅ You can still use GitHub for code management
- ✅ Use GitHub Actions for image building

---

## **🎯 Summary**

**Right now, you can:**
1. **Use manual deployment** (Option 1) - **RECOMMENDED**
2. **Contact your instructor** for service principal help
3. **Set up self-hosted runner** if you want full automation

**You don't need an "instructor" in the traditional sense** - you just need someone with Azure Active Directory admin permissions to create service principals for you.

Would you like me to help you set up the manual deployment approach first?
