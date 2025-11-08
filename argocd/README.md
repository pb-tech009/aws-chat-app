


🔍 Access ArgoCD Locally in Kind
1. Check if ArgoCD is Running
kubectl get pods -n argocd
2. Get ArgoCD Admin Password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
3. Port Forward to Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
4. Access ArgoCD Dashboard
Open your browser and go to:

https://localhost:8080
Login credentials:


w# 🚀 ArgoCD GitOps Configuration

This directory contains ArgoCD applications and projects for automated deployment of the chat-app.

## 📁 Structure

```
argocd/
├── projects/
│   └── chat-app-project.yaml    # ArgoCD project definition
├── applications/
│   ├── chat-app-main.yaml       # Main application (frontend + backend + mongodb)
│   └── chat-app-jobs.yaml       # Jobs and CronJobs
└── README.md                    # This file
```

## 🔄 GitOps Workflow

### 1. **Code Change → Build**
```
Developer pushes code → GitHub Actions → Build Docker → Push to ECR → Update Helm values
```

### 2. **Helm Update → Deploy**
```
Helm values updated → ArgoCD detects change → Deploys to Kubernetes → Monitors health
```

## 🎯 Applications

### **chat-app-main**
- **Purpose**: Main chat application deployment
- **Components**: Frontend, Backend, MongoDB, Ingress
- **Sync Wave**: 1 (deploys first)
- **Auto-sync**: Enabled with self-heal

### **chat-app-jobs**
- **Purpose**: Maintenance jobs and CronJobs
- **Components**: Backups, cleanup, monitoring jobs
- **Sync Wave**: 2 (deploys after main app)
- **Auto-sync**: Enabled

## 🛡️ Security & RBAC

### **Project Roles**
- **Admin**: Full access to all applications and repositories
- **Developer**: Read and sync access to applications

### **Resource Whitelist**
- Only approved Kubernetes resources can be deployed
- Cluster-level resources require explicit permission
- Namespace resources are restricted to safe operations

## 📊 Monitoring

### **Sync Status**
- **Synced**: Application matches Git state
- **OutOfSync**: Differences detected, will auto-sync
- **Progressing**: Deployment in progress
- **Healthy**: All resources running correctly

### **Sync Waves**
1. **Wave 1**: Core application components
2. **Wave 2**: Supporting services and jobs

## 🔧 Management

### **Access ArgoCD Dashboard**
```bash
# Get LoadBalancer URL
kubectl get svc -n argocd argocd-server

# Or port-forward if using ClusterIP
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### **Get Admin Password**
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### **Manual Sync**
```bash
# Sync main application
argocd app sync chat-app-main

# Sync jobs
argocd app sync chat-app-jobs
```

## 🎯 Sync Policies

### **Automated Sync**
- **Prune**: Remove resources not in Git
- **Self-Heal**: Fix manual changes automatically
- **Retry**: Automatic retry on failures

### **Sync Options**
- **CreateNamespace**: Auto-create target namespace
- **PrunePropagationPolicy**: Proper resource cleanup
- **PruneLast**: Delete resources in correct order

## 🚀 Benefits

✅ **Automated Deployments**: Code changes trigger automatic deployments  
✅ **GitOps Compliance**: Git as single source of truth  
✅ **Rollback Capability**: Easy rollback to previous versions  
✅ **Health Monitoring**: Continuous application health checks  
✅ **Security**: RBAC and resource restrictions  
✅ **Audit Trail**: Complete deployment history  

Your chat-app now has enterprise-grade GitOps automation! 🎉