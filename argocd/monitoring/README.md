# 📊 ArgoCD Monitoring Setup

## What This Folder Contains

### ✅ `metrics.yaml` - Prometheus Metrics Collection

**What it collects:**
- ArgoCD application sync statistics
- ArgoCD health status numbers
- API request counts and duration
- Git operation performance
- Notification delivery statistics

**What it does NOT collect:**
- Application logs (text messages)
- Pod logs from chat-app
- Error messages from your application

## 📊 Metrics vs Logs

### Metrics (Numbers/Statistics)
```
✅ Application sync count: 15
✅ Health status: Healthy (2)
✅ Sync duration: 5.3 seconds
✅ API requests: 1,234
✅ Git fetch time: 2.1 seconds
```

### Logs (Text Messages)
```
❌ "User logged in successfully"
❌ "Error: Connection timeout"
❌ "Starting server on port 5001"
❌ "MongoDB connected"
```

## 🚀 What You Get with `metrics.yaml`

### ArgoCD Metrics Only
Your `metrics.yaml` monitors **ArgoCD itself**, not your chat application:

**ArgoCD Application Controller:**
- `argocd_app_info` - Which apps are deployed
- `argocd_app_sync_total` - How many times apps synced
- `argocd_app_health_status` - Is app healthy? (0-5)
- `argocd_app_sync_status` - Is app synced? (0-2)
- `argocd_app_reconcile_duration_seconds` - How long reconciliation takes

**ArgoCD API Server:**
- `argocd_api_request_total` - API request count
- `argocd_api_request_duration_seconds` - API latency

**ArgoCD Repo Server:**
- `argocd_git_request_total` - Git operations
- `argocd_git_request_duration_seconds` - Git fetch time
- `argocd_helm_template_render_duration_seconds` - Helm rendering time

**ArgoCD Notifications:**
- `argocd_notifications_deliveries_total` - Emails sent
- `argocd_notifications_send_success` - Successful notifications
- `argocd_notifications_send_error` - Failed notifications

**ArgoCD ApplicationSet:**
- `argocd_applicationset_reconcile_count` - Reconciliation count
- `argocd_applicationset_reconcile_duration_seconds` - Duration

## 📈 Example Prometheus Queries

### Check Application Health
```promql
argocd_app_health_status{name="chat-app-main"}
# Returns: 2 (Healthy), 4 (Degraded), etc.
```

### Count Total Syncs
```promql
sum(argocd_app_sync_total)
# Returns: Total number of sync operations
```

### Check Sync Status
```promql
argocd_app_sync_status{name="chat-app-main"}
# Returns: 1 (Synced), 2 (OutOfSync)
```

### API Request Rate (last 5 minutes)
```promql
rate(argocd_api_request_total[5m])
# Returns: Requests per second
```

### Git Operation Duration
```promql
argocd_git_request_duration_seconds
# Returns: Time taken for git operations
```

### Notification Success Rate
```promql
rate(argocd_notifications_deliveries_total{succeeded="true"}[5m])
# Returns: Successful notifications per second
```

## 🎯 What You Can Monitor

### ✅ With Current Setup (metrics.yaml)
- ArgoCD application deployment status
- ArgoCD sync operations
- ArgoCD API performance
- ArgoCD git operations
- ArgoCD notification delivery
- ArgoCD health and status

### ❌ NOT Included (Need Additional Setup)
- Chat-app backend logs
- Chat-app frontend logs
- MongoDB logs
- Application error messages
- User activity logs
- Database query logs

## 🔧 Setup Instructions

### 1. Apply ServiceMonitors
```bash
kubectl apply -f argocd/monitoring/metrics.yaml
```

### 2. Verify ServiceMonitors Created
```bash
kubectl get servicemonitor -n argocd
```

Expected output:
```
NAME                                      AGE
argocd-metrics                           10s
argocd-server-metrics                    10s
argocd-repo-server-metrics              10s
argocd-applicationset-controller-metrics 10s
argocd-notifications-controller-metrics  10s
```

### 3. Check Prometheus is Scraping
```bash
# Port forward to Prometheus
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090

# Open browser: http://localhost:9090
# Go to: Status → Targets
# Look for: argocd/* targets (should be UP)
```

### 4. Query Metrics in Prometheus
```bash
# In Prometheus UI, try these queries:
argocd_app_info
argocd_app_health_status
argocd_app_sync_total
```

## 📊 Grafana Dashboards (Optional)

Import these ArgoCD dashboards from Grafana.com:

1. **ArgoCD Overview** - Dashboard ID: 14584
   - Application status overview
   - Sync statistics
   - Health metrics

2. **ArgoCD Application** - Dashboard ID: 19993
   - Per-application metrics
   - Sync history
   - Resource status

3. **ArgoCD Notifications** - Dashboard ID: 19974
   - Notification delivery stats
   - Success/failure rates
   - Trigger evaluations

## 🔍 Troubleshooting

### ServiceMonitors Not Working?

**Check if Prometheus Operator is installed:**
```bash
kubectl get crd servicemonitors.monitoring.coreos.com
```

**Check ServiceMonitor labels:**
```bash
kubectl get servicemonitor -n argocd -o yaml
# Look for: release: kube-prometheus-stack
```

**Check if Prometheus is finding targets:**
```bash
kubectl logs -n monitoring -l app.kubernetes.io/name=prometheus
```

### No Metrics Showing?

**Verify ArgoCD services have metrics ports:**
```bash
kubectl get svc -n argocd
# Look for services with 'metrics' port
```

**Check if metrics endpoint is accessible:**
```bash
kubectl port-forward -n argocd svc/argocd-metrics 8082:8082
curl http://localhost:8082/metrics
# Should return Prometheus metrics
```

## 📝 Summary

### ✅ What `metrics.yaml` Does
- Collects **ArgoCD metrics** (numbers/statistics)
- Monitors ArgoCD deployment operations
- Tracks ArgoCD performance
- Monitors notification delivery
- Provides data for Prometheus/Grafana

### ❌ What `metrics.yaml` Does NOT Do
- Does NOT collect application logs
- Does NOT collect chat-app logs
- Does NOT collect pod logs
- Does NOT collect error messages

### 🎯 Result
You get **complete visibility into ArgoCD operations**, including:
- When your chat-app was deployed
- If deployment was successful
- How long deployment took
- If notifications were sent
- ArgoCD health and performance

For **application logs** (chat-app logs), you need a separate logging solution like:
- ELK Stack (Elasticsearch, Logstash, Kibana)
- Loki + Promtail
- Fluentd + Elasticsearch
- CloudWatch Logs (AWS)

---

**Current Status:** ✅ ArgoCD Metrics Collection Ready  
**Application Logs:** ⏸️ Not included (separate setup needed)
