# ArgoCD Email Notifications Setup

This directory contains configuration for ArgoCD email notifications to `b.parthchauhan@gmail.com`.

## 📋 Prerequisites

### Gmail App Password Setup

Since you're using Gmail, you need to create an **App Password** (not your regular Gmail password):

1. Go to your Google Account: https://myaccount.google.com/
2. Navigate to **Security**
3. Enable **2-Step Verification** (if not already enabled)
4. Go to **App passwords** (search for it in settings)
5. Select **Mail** and **Other (Custom name)**
6. Name it "ArgoCD Notifications"
7. Click **Generate**
8. Copy the 16-character password (e.g., `abcd efgh ijkl mnop`)

## 🚀 Installation Steps

### Step 1: Install ArgoCD Notifications Controller
```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/notifications_catalog/install.yaml
```

### Step 2: Update Secret with Gmail App Password
Edit `argocd-notifications-secret.yaml` and replace `your-gmail-app-password` with your actual Gmail App Password:

```yaml
stringData:
  email-username: "b.parthchauhan@gmail.com"
  email-password: "abcd efgh ijkl mnop"  # Your 16-character App Password
```

### Step 3: Update ArgoCD URL
Edit `argocd-notifications-cm.yaml` and update the ArgoCD URL:

```yaml
context: |
  argocdUrl: "https://your-argocd-url"  # Replace with actual URL
```

### Step 4: Apply the Configurations
```bash
# Apply the secret
kubectl apply -f argocd/notifications/argocd-notifications-secret.yaml

# Apply the ConfigMap
kubectl apply -f argocd/notifications/argocd-notifications-cm.yaml
```

### Step 5: Enable Notifications for Your Applications
Add annotations to your ArgoCD applications:

```bash
# For chat-app-main
kubectl patch application chat-app-main -n argocd --type merge -p '{"metadata":{"annotations":{"notifications.argoproj.io/subscribe.on-deployed.email":"b.parthchauhan@gmail.com","notifications.argoproj.io/subscribe.on-health-degraded.email":"b.parthchauhan@gmail.com"}}}'

# For chat-app-jobs
kubectl patch application chat-app-jobs -n argocd --type merge -p '{"metadata":{"annotations":{"notifications.argoproj.io/subscribe.on-deployed.email":"b.parthchauhan@gmail.com","notifications.argoproj.io/subscribe.on-health-degraded.email":"b.parthchauhan@gmail.com"}}}'
```

## ✅ Verify Setup

### Check Notifications Controller
```bash
kubectl get pods -n argocd | grep notifications
```

### Check Secret
```bash
kubectl get secret argocd-notifications-secret -n argocd
```

### Check ConfigMap
```bash
kubectl get configmap argocd-notifications-cm -n argocd
```

### Test Notification
```bash
# Trigger a sync to test
kubectl patch application chat-app-main -n argocd --type merge -p '{"operation":{"sync":{}}}'
```

## 📧 What You'll Receive

### On Successful Deployment:
- **Subject:** `[ArgoCD] chat-app-main successfully deployed 🎉`
- **Content:** Application details, sync status, health status, and ArgoCD link

### On Health Degraded:
- **Subject:** `[ArgoCD] chat-app-main health is Degraded`
- **Content:** Application details, health message, and troubleshooting link

## 🔧 Troubleshooting

### Not Receiving Emails?

1. **Check Gmail App Password:**
   ```bash
   kubectl get secret argocd-notifications-secret -n argocd -o yaml
   ```

2. **Check Notifications Controller Logs:**
   ```bash
   kubectl logs -n argocd -l app.kubernetes.io/name=argocd-notifications-controller
   ```

3. **Verify Application Annotations:**
   ```bash
   kubectl get application chat-app-main -n argocd -o yaml | grep notifications
   ```

4. **Test SMTP Connection:**
   ```bash
   kubectl exec -n argocd deployment/argocd-notifications-controller -- \
     argocd-notifications template notify email-deployed chat-app-main \
     --recipient b.parthchauhan@gmail.com
   ```

### Common Issues:

- **"Authentication failed"**: Wrong App Password or 2FA not enabled
- **"Connection refused"**: Check if port 465 is accessible
- **"No notifications"**: Application annotations not set correctly

## 📝 Notes

- Gmail App Password is required (regular password won't work)
- Notifications are sent only when triggers match (deployed or degraded)
- You can add more email recipients by adding more annotations
- Check spam folder if emails don't appear in inbox
