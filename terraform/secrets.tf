# =============================================================================
# AWS SECRETS MANAGER CONFIGURATION
# =============================================================================

# Random password generation for production secrets
resource "random_password" "mongodb_password" {
  length  = 32
  special = true
}

resource "random_password" "jwt_secret" {
  length  = 64
  special = false
}

# =============================================================================
# MONGODB CREDENTIALS
# =============================================================================

resource "aws_secretsmanager_secret" "mongodb_credentials" {
  name                    = "chat-app/mongodb/credentials"
  description             = "MongoDB credentials for chat application"
  recovery_window_in_days = 7

  tags = merge(local.common_tags, {
    Component = "database"
    Secret    = "mongodb-credentials"
  })
}

resource "aws_secretsmanager_secret_version" "mongodb_credentials" {
  secret_id = aws_secretsmanager_secret.mongodb_credentials.id
  secret_string = jsonencode({
    username = "mongoadmin"
    password = random_password.mongodb_password.result
  })
}

# =============================================================================
# JWT SECRET
# =============================================================================

resource "aws_secretsmanager_secret" "jwt_secret" {
  name                    = "chat-app/backend/jwt-secret"
  description             = "JWT secret for chat application backend"
  recovery_window_in_days = 7

  tags = merge(local.common_tags, {
    Component = "backend"
    Secret    = "jwt-secret"
  })
}

resource "aws_secretsmanager_secret_version" "jwt_secret" {
  secret_id = aws_secretsmanager_secret.jwt_secret.id
  secret_string = jsonencode({
    jwt_secret = random_password.jwt_secret.result
  })
}

# =============================================================================
# CLOUDINARY CREDENTIALS (Placeholder)
# =============================================================================

resource "aws_secretsmanager_secret" "cloudinary_credentials" {
  name                    = "chat-app/cloudinary/credentials"
  description             = "Cloudinary credentials for chat application"
  recovery_window_in_days = 7

  tags = merge(local.common_tags, {
    Component = "storage"
    Secret    = "cloudinary-credentials"
  })
}

resource "aws_secretsmanager_secret_version" "cloudinary_credentials" {
  secret_id = aws_secretsmanager_secret.cloudinary_credentials.id
  secret_string = jsonencode({
    cloud_name = var.cloudinary_cloud_name
    api_key    = var.cloudinary_api_key
    api_secret = var.cloudinary_api_secret
  })
}

# =============================================================================
# IAM ROLE FOR EXTERNAL SECRETS OPERATOR
# =============================================================================

data "aws_iam_policy_document" "external_secrets_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.chat_app_eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:external-secrets-system:external-secrets"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.chat_app_eks.cluster_oidc_issuer_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [module.chat_app_eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "external_secrets" {
  name               = "${local.cluster_name}-external-secrets-role"
  assume_role_policy = data.aws_iam_policy_document.external_secrets_assume_role.json

  tags = local.common_tags
}

data "aws_iam_policy_document" "external_secrets_policy" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [
      aws_secretsmanager_secret.mongodb_credentials.arn,
      aws_secretsmanager_secret.jwt_secret.arn,
      aws_secretsmanager_secret.cloudinary_credentials.arn
    ]
  }
}

resource "aws_iam_policy" "external_secrets" {
  name   = "${local.cluster_name}-external-secrets-policy"
  policy = data.aws_iam_policy_document.external_secrets_policy.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "external_secrets" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.external_secrets.arn
}

# =============================================================================
# KUBERNETES SECRET FOR AWS CREDENTIALS
# =============================================================================

resource "kubernetes_secret" "aws_credentials" {
  metadata {
    name      = "aws-credentials"
    namespace = "chat-app"
  }

  data = {
    access-key-id     = ""  # Will be populated by External Secrets Operator using IRSA
    secret-access-key = ""  # Will be populated by External Secrets Operator using IRSA
  }

  depends_on = [module.chat_app_eks]
}

# =============================================================================
# SERVICE ACCOUNT ANNOTATION FOR IRSA
# =============================================================================

resource "kubernetes_service_account" "external_secrets" {
  metadata {
    name      = "external-secrets"
    namespace = "external-secrets-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets.arn
    }
  }

  depends_on = [module.eks_addons]
}