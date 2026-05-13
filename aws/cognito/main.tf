data "aws_region" "current" {}

locals {
  merged_tags = merge({ FreeTier = "true" }, var.tags)

  # Determine which domain identifier to use for the hosted-UI URL
  use_custom_domain    = var.enable_hosted_ui && var.custom_domain != ""
  use_prefix_domain    = var.enable_hosted_ui && var.domain_prefix != "" && var.custom_domain == ""
  cognito_domain_label = local.use_prefix_domain ? aws_cognito_user_pool_domain.prefix[0].domain : (local.use_custom_domain ? var.custom_domain : "")
}

# ---------------------------------------------------------------------------
# Cognito User Pool
# Always-free: 50,000 MAUs/month
# ---------------------------------------------------------------------------

resource "aws_cognito_user_pool" "main" {
  name = var.name

  # Self-registration
  admin_create_user_config {
    allow_admin_create_user_only = !var.allow_self_registration
  }

  # Automatic email verification
  auto_verified_attributes = var.auto_verify_email ? ["email"] : []

  # Username attributes — sign in with email address
  username_attributes = ["email"]

  username_configuration {
    case_sensitive = false
  }

  # Password policy
  password_policy {
    minimum_length                   = var.password_minimum_length
    require_uppercase                = var.password_require_uppercase
    require_lowercase                = var.password_require_lowercase
    require_numbers                  = var.password_require_numbers
    require_symbols                  = var.password_require_symbols
    temporary_password_validity_days = 7
  }

  mfa_configuration = var.mfa_configuration

  # Standard email schema attribute
  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = true
    mutable             = true

    string_attribute_constraints {
      min_length = 1
      max_length = 254
    }
  }

  tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# App Client (public — no client secret, for SPA / static frontend)
# ---------------------------------------------------------------------------

resource "aws_cognito_user_pool_client" "main" {
  name         = "${var.name}-client"
  user_pool_id = aws_cognito_user_pool.main.id

  # Public client: no secret
  generate_secret = false

  # Allowed auth flows: USER_SRP_AUTH for secure browser-based sign-in
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]

  # OAuth 2.0 settings — only populated when callback_urls are provided
  allowed_oauth_flows_user_pool_client = length(var.callback_urls) > 0
  allowed_oauth_flows                  = length(var.callback_urls) > 0 ? var.allowed_oauth_flows : []
  allowed_oauth_scopes                 = length(var.callback_urls) > 0 ? var.allowed_oauth_scopes : []
  supported_identity_providers         = length(var.callback_urls) > 0 ? var.supported_identity_providers : []
  callback_urls                        = length(var.callback_urls) > 0 ? var.callback_urls : null
  logout_urls                          = length(var.logout_urls) > 0 ? var.logout_urls : null

  # Token validity
  access_token_validity  = var.token_validity_hours
  id_token_validity      = var.token_validity_hours
  refresh_token_validity = var.refresh_token_validity_days

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  prevent_user_existence_errors = "ENABLED"
}

# ---------------------------------------------------------------------------
# User Pool Domain — Cognito-managed prefix (free)
# ---------------------------------------------------------------------------

resource "aws_cognito_user_pool_domain" "prefix" {
  count = local.use_prefix_domain ? 1 : 0

  domain       = var.domain_prefix
  user_pool_id = aws_cognito_user_pool.main.id
}

# ---------------------------------------------------------------------------
# User Pool Domain — custom domain (requires ACM certificate in us-east-1)
# ---------------------------------------------------------------------------

resource "aws_cognito_user_pool_domain" "custom" {
  count = local.use_custom_domain ? 1 : 0

  domain          = var.custom_domain
  certificate_arn = var.custom_domain_certificate_arn
  user_pool_id    = aws_cognito_user_pool.main.id
}
