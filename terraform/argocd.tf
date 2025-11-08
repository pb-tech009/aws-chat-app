# =============================================================================
# ARGOCD INSTALLATION AND CONFIGURATION
# =============================================================================

# Wait for the cluster and add-ons to be ready
resource "time_sleep" "wait_for_cluster" {
  create_duration = "30s"
  depends_on = [
    module.chat_app_eks,
    module.eks_addons
  ]
}

# =============================================================================
# ARGOCD HELM INSTALLATION
# =============================================================================

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = var.argocd_namespace
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version

  # ArgoCD configuration values
  values = [
    yamlencode({
      # Global configuration
      global = {
        image = {
          tag = "v2.8.4"  # Stable version
        }
      }
      
      # Server configuration
      server = {
        service = {
          type = "LoadBalancer"  # Changed to LoadBalancer for easy access
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
            "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
          }
        }
        ingress = {
          enabled = false
        }
        # Enable insecure mode for easier access
        extraArgs = [
          "--insecure"
        ]
        # Auto-sync configuration
        config = {
          "application.instanceLabelKey" = "argocd.argoproj.io/instance"
          "server.rbac.log.enforce.enable" = "true"
          "exec.enabled" = "true"
          "admin.enabled" = "true"
          "timeout.reconciliation" = "180s"
          "timeout.hard.reconciliation" = "0s"
        }
        rbacConfig = {
          "policy.default" = "role:readonly"
          "policy.csv" = <<-EOT
            p, role:admin, applications, *, */*, allow
            p, role:admin, clusters, *, *, allow
            p, role:admin, repositories, *, *, allow
            g, argocd-admins, role:admin
          EOT
        }
      }
      
      # Controller configuration
      controller = {
        replicas = 1
        resources = {
          requests = {
            cpu    = "250m"
            memory = "512Mi"
          }
          limits = {
            cpu    = "1000m"
            memory = "1Gi"
          }
        }
        # Application sync settings
        env = [
          {
            name = "ARGOCD_CONTROLLER_REPLICAS"
            value = "1"
          }
        ]
        metrics = {
          enabled = true
          serviceMonitor = {
            enabled = true
          }
        }
      }
      
      # Repo server configuration
      repoServer = {
        replicas = 1
        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
        metrics = {
          enabled = true
          serviceMonitor = {
            enabled = true
          }
        }
      }
      
      # Redis configuration
      redis = {
        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "256Mi"
          }
        }
        metrics = {
          enabled = true
          serviceMonitor = {
            enabled = true
          }
        }
      }
      
      # ApplicationSet controller (for advanced GitOps)
      applicationSet = {
        enabled = true
        replicas = 1
        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
      }
      
      # Notifications controller
      notifications = {
        enabled = true
        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
      }
    })
  ]

  depends_on = [time_sleep.wait_for_cluster]
}

# =============================================================================
# ARGOCD PROJECT CONFIGURATION
# =============================================================================

resource "kubectl_manifest" "argocd_project" {
  yaml_body = file("${path.module}/../argocd/projects/chat-app-project.yaml")
  depends_on = [helm_release.argocd]
}

# =============================================================================
# ARGOCD APPLICATIONS
# =============================================================================

resource "kubectl_manifest" "argocd_app_main" {
  yaml_body = file("${path.module}/../argocd/applications/chat-app-main.yaml")
  depends_on = [kubectl_manifest.argocd_project]
}

resource "kubectl_manifest" "argocd_app_jobs" {
  yaml_body = file("${path.module}/../argocd/applications/chat-app-jobs.yaml")
  depends_on = [kubectl_manifest.argocd_project]
}

# =============================================================================
# ARGOCD REPOSITORY SECRET (for private repos)
# =============================================================================

resource "kubernetes_secret" "argocd_repo_secret" {
  metadata {
    name      = "chat-app-repo"
    namespace = var.argocd_namespace
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type = "git"
    url  = "https://github.com/pb-tech009/aws-chat-app"
    # For private repos, add:
    # username = var.github_username
    # password = var.github_token
  }

  depends_on = [helm_release.argocd]
}

# =============================================================================
# ARGOCD WEBHOOK CONFIGURATION (for instant sync)
# =============================================================================

resource "kubernetes_secret" "argocd_webhook_secret" {
  metadata {
    name      = "argocd-webhook-secret"
    namespace = var.argocd_namespace
  }

  data = {
    webhook.github.secret = "chat-app-webhook-2024"  # Change this for security!
  }

  depends_on = [helm_release.argocd]
}
