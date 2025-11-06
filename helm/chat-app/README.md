# 🚀 Chat-App Helm Chart

This Helm chart deploys your complete chat application with MongoDB, Backend, and Frontend using your exact YAML configurations.

## 📁 **Chart Structure**

```
helm/chat-app/
├── Chart.yaml                    # Chart metadata
├── values.yaml                   # Default values
├── values-dev.yaml              # Development overrides
├── values-prod.yaml             # Production overrides
├── README.md                    # This file
└── templates/
    ├── namespace.yaml           # Namespace creation
    ├── secrets.yaml             # App secrets
    ├── mongodb/
    │   ├── statefulset.yaml     # MongoDB StatefulSet
    │   ├── service.yaml         # MongoDB Service
    │   └── vpa.yaml             # Vertical Pod Autoscaler
    ├── backend/
    │   ├── deployment.yaml      # Backend Deployment
    │   ├── service.yaml         # Backend Service
    │   └── hpa.yaml             # Horizontal Pod Autoscaler
    ├── frontend/
    │   ├── deployment.yaml      # Frontend Deployment
    │   ├── service.yaml         # Frontend Service
    │   └── hpa.yaml             # Horizontal Pod Autoscaler
    └── ingress.yaml             # Ingress with WebSocket support
```

## 🛠 **Installation**

### **Prerequisites**
```bash
# Install Helm (if not already installed)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify Helm installation
helm version
```

### **1. Development Deployment (Kind)**
```bash
# Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Deploy chat-app with development values
helm install chat-app ./helm/chat-app -f ./helm/chat-app/values-dev.yaml

# Check deployment status
helm status chat-app
kubectl get pods -n chat-app

# Access your app
echo "Frontend: http://localhost"
echo "API: http://localhost/api"
echo "WebSocket: ws://localhost/socket.io"
```

### **2. Production Deployment (EKS)**
```bash
# Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/aws/deploy.yaml

# Install cert-manager for SSL
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml

# Deploy chat-app with production values
helm install chat-app ./helm/chat-app -f ./helm/chat-app/values-prod.yaml

# Check deployment status
helm status chat-app
kubectl get pods -n chat-app

# Get LoadBalancer URL
kubectl get svc -n ingress-nginx ingress-nginx-controller

# Access your app
echo "Frontend: https://chat-app.com"
echo "API: https://chat-app.com/api"
echo "WebSocket: wss://chat-app.com/socket.io"
```

## 🔧 **Management Commands**

### **Upgrade Deployment**
```bash
# Update with new values
helm upgrade chat-app ./helm/chat-app -f ./helm/chat-app/values-prod.yaml

# Update specific values
helm upgrade chat-app ./helm/chat-app --set backend.replicas=3
```

### **Rollback Deployment**
```bash
# List releases
helm history chat-app

# Rollback to previous version
helm rollback chat-app 1
```

### **Uninstall**
```bash
# Remove the deployment
helm uninstall chat-app

# Clean up namespace (if needed)
kubectl delete namespace chat-app
```

## 📊 **Monitoring**

### **Check Status**
```bash
# Helm status
helm status chat-app

# Pod status
kubectl get pods -n chat-app

# Service status
kubectl get svc -n chat-app

# Ingress status
kubectl get ingress -n chat-app

# HPA status
kubectl get hpa -n chat-app
```

### **View Logs**
```bash
# Frontend logs
kubectl logs -n chat-app -l app=frontend

# Backend logs
kubectl logs -n chat-app -l app=backend

# MongoDB logs
kubectl logs -n chat-app -l app=mongodb
```

## ⚙️ **Configuration**

### **Environment-Specific Values**

#### **Development (`values-dev.yaml`):**
- Single MongoDB replica
- Minimal resource requests
- HPA disabled
- HTTP only (no SSL)
- localhost access

#### **Production (`values-prod.yaml`):**
- 3 MongoDB replicas
- Higher resource limits
- HPA enabled (2-10 replicas)
- SSL/TLS enabled
- Production domains

### **Custom Configuration**
```bash
# Override specific values
helm install chat-app ./helm/chat-app \
  --set backend.replicas=5 \
  --set frontend.replicas=3 \
  --set mongodb.storage.size=50Gi

# Use custom values file
helm install chat-app ./helm/chat-app -f my-custom-values.yaml
```

## 🎯 **Benefits of This Helm Chart**

✅ **Single Command Deployment** - No more managing 12+ YAML files  
✅ **Environment Management** - Easy dev/prod configurations  
✅ **Version Control** - Track and rollback deployments  
✅ **Template Reuse** - Same chart for different environments  
✅ **Dependency Management** - Automatic deployment order  
✅ **Configuration Management** - Centralized values  
✅ **Production Ready** - HPA, VPA, SSL, monitoring  

## 🚀 **Your Original YAML Files**

This Helm chart uses your exact YAML configurations:
- ✅ Same container images (`parth1509/chatbackend:latest`, `parth1509/chatfrontend:latest`)
- ✅ Same environment variables and secrets
- ✅ Same resource limits and requests
- ✅ Same MongoDB StatefulSet configuration
- ✅ Same ingress rules and WebSocket support
- ✅ Same HPA and VPA settings

**Nothing changed in your working code - just organized into a manageable Helm chart!** 🎉