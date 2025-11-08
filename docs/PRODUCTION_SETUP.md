# 🚀 Production Setup Guide

This guide covers the complete production deployment setup for the Chat Application with enterprise-grade security and monitoring.

## 📋 Prerequisites

### Required Tools
- AWS CLI v2.x configured with appropriate permissions
- Terraform >= 1.0
- kubectl >= 1.28
- Helm >= 3.12
- Docker >= 20.10

### AWS Permissions Required
- EKS Full Access
- EC2 Full Access
- VPC Full Access
- Secrets Manager Full Access
- ECR Full Access
- IAM permissions for role creation

## 🔧 Step 1: Configure Secrets

### 1.1 Set Cloudinary Credentials
```bash
# Set your Cloudinary credentials as Terraform variables
export TF_VAR_cloudinary_cloud_name="your-cloud-name"
export TF_VAR_cloudinary_api_key="your-api-key"
export TF_VAR_cloudinary_api_secret="your-api-secret"
```

### 1.2 Update Production Values
Edit `helm/chat-app/values-prod.yaml`:
- Replace ECR repository URLs with your AWS account ID
- Update domain names to your actual domains
- Replace certificate ARN with your ACM certificate

## 🏗️ Step 2: Deploy Infrastructure

### 2.1 Initialize Terraform
```bash
cd terraform
terraform init
```

### 2.2 Plan and Apply
```bash
# Review the plan
terraform plan -var-file="prod.tfvars"

# Apply infrastructure
terraform apply -var-file="prod.tfvars"
```

### 2.3 Configure kubectl
```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name chat-app-dev

# Verify connection
kubectl get nodes
```

## 🔐 Step 3: Verify Secret Management

### 3.1 Check External Secrets Operator
```bash
# Verify External Secrets Operator is running
kubectl get pods -n external-secrets-system

# Check SecretStore
kubectl get secretstore -n chat-app
```

### 3.2 Verify AWS Secrets
```bash
# List secrets in AWS Secrets Manager
aws secretsmanager list-secrets --query 'SecretList[?contains(Name, `chat-app`)]'

# Test secret retrieval
aws secretsmanager get-secret-value --secret-id chat-app/mongodb/credentials
```

## 🚀 Step 4: Deploy Application

### 4.1 Deploy via ArgoCD
The application will be automatically deployed via ArgoCD after infrastructure setup.

### 4.2 Monitor Deployment
```bash
# Check ArgoCD applications
kubectl get applications -n argocd

# Monitor application sync status
kubectl describe application chat-app-main -n argocd
```

### 4.3 Verify Services
```bash
# Check all pods are running
kubectl get pods -n chat-app

# Check services
kubectl get svc -n chat-app

# Check ingress
kubectl get ingress -n chat-app
```

## 🧪 Step 5: Run Integration Tests

### 5.1 Manual Health Checks
```bash
# Get ALB endpoint
ALB_ENDPOINT=$(kubectl get ingress chatapp-ingress -n chat-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Test frontend
curl -f http://$ALB_ENDPOINT

# Test backend API
curl -f http://$ALB_ENDPOINT/api/auth/check
```

### 5.2 WebSocket Test
```bash
# Create test pod for WebSocket
kubectl run websocket-test --image=node:18-alpine --rm -i --restart=Never -n chat-app -- \
  sh -c "npm install socket.io-client && node -e 'const io = require(\"socket.io-client\"); const socket = io(\"http://backend:5001\"); socket.on(\"connect\", () => { console.log(\"Connected\"); process.exit(0); });'"
```

## 📊 Step 6: Monitoring and Maintenance

### 6.1 ArgoCD Dashboard
```bash
# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### 6.2 Check Backup Jobs
```bash
# Verify backup CronJob
kubectl get cronjobs -n chat-app

# Check backup logs
kubectl logs -l job-name=mongodb-backup -n chat-app
```

### 6.3 Monitor Resource Usage
```bash
# Check HPA status
kubectl get hpa -n chat-app

# Monitor pod resources
kubectl top pods -n chat-app
```

## 🔄 Step 7: CI/CD Integration

### 7.1 GitHub Secrets Configuration
Add these secrets to your GitHub repository:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `AWS_ACCOUNT_ID`

### 7.2 Trigger Deployment
```bash
# Push changes to trigger CI/CD
git add .
git commit -m "feat: deploy to production"
git push origin main
```

## 🚨 Troubleshooting

### Common Issues

#### External Secrets Not Working
```bash
# Check External Secrets Operator logs
kubectl logs -n external-secrets-system -l app.kubernetes.io/name=external-secrets

# Verify IRSA configuration
kubectl describe sa external-secrets -n external-secrets-system
```

#### ArgoCD Sync Issues
```bash
# Force sync application
kubectl patch application chat-app-main -n argocd --type merge -p '{"operation":{"sync":{"syncStrategy":{"hook":{"force":true}}}}}'

# Check ArgoCD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller
```

#### Pod Startup Issues
```bash
# Check pod logs
kubectl logs -l app=backend -n chat-app --tail=100

# Describe pod for events
kubectl describe pod -l app=backend -n chat-app
```

## 🔒 Security Best Practices

1. **Secrets Management**: All secrets are stored in AWS Secrets Manager
2. **Network Security**: Private subnets for worker nodes
3. **RBAC**: Minimal permissions for service accounts
4. **Image Security**: Container vulnerability scanning with Trivy
5. **TLS**: End-to-end encryption with ACM certificates

## 📈 Performance Optimization

1. **Auto Scaling**: HPA configured for all services
2. **Resource Limits**: Proper CPU/memory limits set
3. **Load Balancing**: ALB with health checks
4. **Caching**: Consider adding Redis for session management
5. **CDN**: Use CloudFront for static assets

## 🎯 Next Steps

1. Set up monitoring with Prometheus/Grafana
2. Configure log aggregation with ELK stack
3. Implement blue-green deployments
4. Add performance testing pipeline
5. Set up disaster recovery procedures