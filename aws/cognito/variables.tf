variable "name" {
  description = "Base name used for the user pool and derived resource names"
  type        = string
}

variable "password_minimum_length" {
  description = "Minimum password length for the user pool"
  type        = number
  default     = 8

  validation {
    condition     = var.password_minimum_length >= 6 && var.password_minimum_length <= 99
    error_message = "password_minimum_length must be between 6 and 99."
  }
}

variable "password_require_uppercase" {
  description = "Whether passwords must contain at least one uppercase letter"
  type        = bool
  default     = true
}

variable "password_require_lowercase" {
  description = "Whether passwords must contain at least one lowercase letter"
  type        = bool
  default     = true
}

variable "password_require_numbers" {
  description = "Whether passwords must contain at least one number"
  type        = bool
  default     = true
}

variable "password_require_symbols" {
  description = "Whether passwords must contain at least one symbol"
  type        = bool
  default     = false
}

variable "allow_self_registration" {
  description = "Whether users can register themselves. Set to false to allow only admin-created accounts"
  type        = bool
  default     = true
}

variable "auto_verify_email" {
  description = "Automatically verify the email attribute after sign-up"
  type        = bool
  default     = true
}

variable "mfa_configuration" {
  description = "Multi-factor authentication setting: OFF, ON, or OPTIONAL"
  type        = string
  default     = "OFF"

  validation {
    condition     = contains(["OFF", "ON", "OPTIONAL"], var.mfa_configuration)
    error_message = "mfa_configuration must be OFF, ON, or OPTIONAL."
  }
}

# ---------------------------------------------------------------------------
# App Client
# ---------------------------------------------------------------------------

variable "callback_urls" {
  description = "List of allowed callback (redirect) URLs for the app client"
  type        = list(string)
  default     = []
}

variable "logout_urls" {
  description = "List of allowed logout URLs for the app client"
  type        = list(string)
  default     = []
}

variable "allowed_oauth_flows" {
  description = "List of OAuth flows to enable (code, implicit, client_credentials)"
  type        = list(string)
  default     = ["code"]
}

variable "allowed_oauth_scopes" {
  description = "List of OAuth scopes to allow (openid, email, profile, phone, aws.cognito.signin.user.admin)"
  type        = list(string)
  default     = ["openid", "email", "profile"]
}

variable "supported_identity_providers" {
  description = "Identity providers to associate with the app client (e.g. [\"COGNITO\"])"
  type        = list(string)
  default     = ["COGNITO"]
}

variable "token_validity_hours" {
  description = "Access token validity in hours. Cognito supports 1–24 hours"
  type        = number
  default     = 1

  validation {
    condition     = var.token_validity_hours >= 1 && var.token_validity_hours <= 24
    error_message = "token_validity_hours must be between 1 and 24."
  }
}

variable "refresh_token_validity_days" {
  description = "Refresh token validity in days. Cognito supports 1–3650 days"
  type        = number
  default     = 30

  validation {
    condition     = var.refresh_token_validity_days >= 1 && var.refresh_token_validity_days <= 3650
    error_message = "refresh_token_validity_days must be between 1 and 3650."
  }
}

# ---------------------------------------------------------------------------
# Hosted UI / Domain
# ---------------------------------------------------------------------------

variable "enable_hosted_ui" {
  description = "Create a Cognito user pool domain and enable the Hosted UI"
  type        = bool
  default     = false
}

variable "domain_prefix" {
  description = "Prefix for the Cognito-managed domain (e.g. my-app → my-app.auth.<region>.amazoncognito.com). Required when enable_hosted_ui = true"
  type        = string
  default     = ""
}

variable "custom_domain" {
  description = "Custom domain name for the Hosted UI (e.g. auth.example.com). If set, overrides domain_prefix. Requires an ACM certificate in us-east-1"
  type        = string
  default     = ""
}

variable "custom_domain_certificate_arn" {
  description = "ARN of the ACM certificate in us-east-1 for the custom domain. Required when custom_domain is set"
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# Tags
# ---------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
