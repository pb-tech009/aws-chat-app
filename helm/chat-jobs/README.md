# 🔧 Chat-Jobs Helm Chart

Simplified deployment and management of all Jobs and CronJobs for your chat application.

## 🎯 **What This Solves:**

### **Before (Complex ❌):**
```bash
kubectl apply -f jobs/01-backup-pvc.yml
kubectl apply -f jobs/02-job-secret.yml
kubectl apply -f jobs/02-mongo-seed-configmap.yml
kubectl apply -f jobs/03-mongo-seed-job.yml
# ... 10+ more files in correct order
```

### **After (Simple ✅):**
```bash
# Deploy all jobs with one command
helm install chat-jobs ./helm/chat-jobs
```

## 🚀 **Usage:**

### **Development (Minimal Jobs):**
```bash
helm install chat-jobs ./helm/chat-jobs -f ./helm/chat-jobs/values-dev.yaml
```

### **Production (All Jobs):**
```bash
helm install chat-jobs ./helm/chat-jobs -f ./helm/chat-jobs/values-prod.yaml
```

### **Custom Configuration:**
```bash
# Enable only backup jobs
helm install chat-jobs ./helm/chat-jobs \
  --set jobs.mongoSeed.enabled=false \
  --set cronJobs.notifications.enabled=false

# Change backup schedule
helm install chat-jobs ./helm/chat-jobs \
  --set cronJobs.mongoBackup.schedule="0 3 * * *"
```

## 📊 **Job Status Monitoring:**

### **Check All Jobs:**
```bash
# List all jobs and cronjobs
kubectl get jobs,cronjobs -n chat-app

# Check job status
helm status chat-jobs

# View job logs
kubectl logs -n chat-app job/mongo-seed-job
kubectl logs -n chat-app job/db-migration-job
```

### **Monitor CronJobs:**
```bash
# Check CronJob status
kubectl get cronjobs -n chat-app

# View recent job runs
kubectl get jobs -n chat-app --sort-by=.metadata.creationTimestamp

# Check failed jobs
kubectl get jobs -n chat-app --field-selector=status.failed=1
```

## 🔧 **Management:**

### **Update Jobs:**
```bash
# Update configuration
helm upgrade chat-jobs ./helm/chat-jobs -f values-prod.yaml

# Enable/disable specific jobs
helm upgrade chat-jobs ./helm/chat-jobs --set cronJobs.mongoBackup.enabled=false
```

### **Trigger Manual Jobs:**
```bash
# Trigger backup manually
kubectl create job --from=cronjob/mongodb-backup manual-backup-$(date +%s) -n chat-app

# Run seed job again
kubectl delete job mongo-seed-job -n chat-app
helm upgrade chat-jobs ./helm/chat-jobs
```

## 📋 **Included Jobs:**

### **One-time Jobs:**
- ✅ **MongoDB Seed** - Initial data setup
- ✅ **Database Migration** - Schema updates
- ✅ **MongoDB Restore** - Backup restoration

### **Scheduled CronJobs:**
- ✅ **MongoDB Backup** - Daily at 2AM
- ✅ **Log Cleanup** - Weekly on Sunday
- ✅ **Image Cleanup** - Daily at 3AM
- ✅ **Notifications** - Every 30 minutes
- ✅ **Metrics Export** - Every 15 minutes
- ✅ **Pod Cleanup** - Every 6 hours

## ✅ **Benefits:**

- 🎯 **Single command** deployment
- 📊 **Easy monitoring** with `helm status`
- ⚙️ **Environment-specific** configurations
- 🔄 **Easy updates** and rollbacks
- 📈 **Centralized management**

Your jobs are now as easy to manage as your main application! 🚀