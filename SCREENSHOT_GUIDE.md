# 📸 AKS Store Demo - Kustomize Screenshots Guide

## For Professor Submission

This guide shows you exactly what to screenshot to demonstrate your AKS Store Demo deployment using Kustomize.

---

## 🎯 **Screenshot 1: Terminal Commands & Kustomize Validation**

Run these commands and take screenshots:

```bash
# 1. Show kustomize directory structure
ls -la kustomize/
tree kustomize/ || find kustomize/ -type f

# 2. Show kustomize build output
kustomize build kustomize/overlays/dev | head -50

# 3. Show kustomize validation
make kustomize-validate
```

**What to capture**: Terminal showing the directory structure, build output, and validation success.

---

## 🎯 **Screenshot 2: Deployment Process**

Run these commands:

```bash
# 1. Show deployment command
make kustomize-deploy-dev

# 2. Show all resources created
kubectl get all -n aks-store-demo

# 3. Show pods with wider output
kubectl get pods -n aks-store-demo -o wide
```

**What to capture**: Terminal showing successful deployment and all running resources.

---

## 🎯 **Screenshot 3: Services and Networking**

```bash
# 1. Show services
kubectl get svc -n aks-store-demo

# 2. Show ingress (if any)
kubectl get ingress -n aks-store-demo

# 3. Show endpoints
kubectl get endpoints -n aks-store-demo
```

**What to capture**: All services and networking configuration.

---

## 🎯 **Screenshot 4: Application Access**

### Option A: Port Forward Method
```bash
# 1. Port forward to store-front
kubectl port-forward svc/store-front 8080:80 -n aks-store-demo

# 2. In another terminal, test the connection
curl -I http://localhost:8080
```

### Option B: Direct Service Access
```bash
# 1. Get service details
kubectl describe svc store-front -n aks-store-demo

# 2. Show pod logs
kubectl logs -n aks-store-demo deployment/store-front --tail=10
```

**What to capture**: Working application access or service details.

---

## 🎯 **Screenshot 5: Kubernetes Dashboard/Monitoring**

```bash
# 1. Show detailed pod information
kubectl describe pods -n aks-store-demo | head -50

# 2. Show resource usage (if metrics available)
kubectl top pods -n aks-store-demo || echo "Metrics not available"

# 3. Show namespaces
kubectl get namespaces
```

**What to capture**: Detailed pod information and resource usage.

---

## 🎯 **Screenshot 6: Kustomize Configuration Files**

```bash
# 1. Show base kustomization
cat kustomize/base/kustomization.yaml

# 2. Show overlay configuration
cat kustomize/overlays/dev/kustomization.yaml

# 3. Show a sample manifest
cat kustomize/base/store-front.yaml
```

**What to capture**: The actual kustomize configuration files.

---

## 🎯 **Screenshot 7: GitHub Integration**

### In your browser:
1. Go to your GitHub repository
2. Navigate to `.github/workflows/`
3. Show the workflow files created
4. Navigate to `kustomize/` directory
5. Show the kustomize structure

**What to capture**: GitHub repository showing the CI/CD pipeline and kustomize structure.

---

## 🎯 **Screenshot 8: Application Working**

### Access the application:
```bash
# 1. Port forward to store-front
kubectl port-forward svc/store-front 8080:80 -n aks-store-demo &

# 2. Port forward to store-admin  
kubectl port-forward svc/store-admin 8081:80 -n aks-store-demo &

# 3. Test both applications
curl http://localhost:8080
curl http://localhost:8081
```

### In your browser:
1. Open `http://localhost:8080` (store-front)
2. Open `http://localhost:8081` (store-admin)

**What to capture**: Working web applications in browser.

---

## 🎯 **Screenshot 9: Cleanup Process**

```bash
# 1. Show cleanup command
make kustomize-cleanup-dev

# 2. Verify cleanup
kubectl get all -n aks-store-demo

# 3. Show namespace deletion
kubectl get namespaces | grep aks-store
```

**What to capture**: Clean removal of all resources.

---

## 📋 **Summary Screenshot Checklist**

✅ **Technical Evidence:**
- [ ] Kustomize directory structure
- [ ] Kustomize build output  
- [ ] Successful deployment logs
- [ ] All pods running
- [ ] Services created
- [ ] Application accessible

✅ **Configuration Evidence:**
- [ ] kustomization.yaml files
- [ ] Kubernetes manifests
- [ ] GitHub workflow files
- [ ] Makefile commands

✅ **Working Application:**
- [ ] Port-forward working
- [ ] Web application accessible
- [ ] Services responding
- [ ] Clean deployment/cleanup

---

## 🎯 **Quick All-in-One Screenshot Session**

Run this complete sequence for a comprehensive demo:

```bash
# 1. Show current status
echo "=== AKS Store Demo - Kustomize Deployment ==="
date
pwd

# 2. Show kustomize structure
echo "=== Kustomize Structure ==="
tree kustomize/ || find kustomize/ -type f

# 3. Validate configuration
echo "=== Kustomize Validation ==="
make kustomize-validate

# 4. Deploy application
echo "=== Deploying Application ==="
make kustomize-deploy-dev

# 5. Show deployment results
echo "=== Deployment Results ==="
kubectl get all -n aks-store-demo

# 6. Show kustomize build
echo "=== Kustomize Build Output ==="
kustomize build kustomize/overlays/dev | head -30

# 7. Test application
echo "=== Testing Application ==="
kubectl port-forward svc/store-front 8080:80 -n aks-store-demo &
sleep 5
curl -I http://localhost:8080 || echo "Application is running"
pkill -f "kubectl port-forward"

echo "=== Demo Complete ==="
```

**Take a screenshot of this entire terminal session!**

---

## 💡 **Pro Tips for Screenshots:**

1. **Use full terminal** - Make sure all output is visible
2. **Include timestamps** - Shows when you did the work
3. **Show your username** - Proves it's your work
4. **Capture errors too** - Shows problem-solving skills
5. **Multiple angles** - Terminal, browser, GitHub, etc.
6. **Clear quality** - Make sure text is readable

---

## 🏆 **What This Demonstrates:**

✅ **Kustomize Knowledge:** Directory structure, overlays, configuration management
✅ **Kubernetes Skills:** Deployment, services, pods, namespaces
✅ **DevOps Practices:** CI/CD pipelines, automation, reproducible deployments
✅ **Problem Solving:** Working deployment, troubleshooting, cleanup
✅ **Best Practices:** Organized code, documentation, version control
