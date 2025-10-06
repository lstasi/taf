variable "bucket_name" {
  description = "Name of the S3 bucket (must be globally unique)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name)) && length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "Bucket name must be 3-63 characters, lowercase alphanumeric and hyphens only."
  }
}

variable "force_destroy" {
  description = "Allow bucket to be destroyed even if it contains objects"
  type        = bool
  default     = false
}

variable "block_public_access" {
  description = "Block all public access to the bucket (recommended for security)"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (leave empty for AES256)"
  type        = string
  default     = ""
}

variable "enable_versioning" {
  description = "Enable versioning for the bucket (incurs storage costs for old versions)"
  type        = bool
  default     = false
}

variable "enable_lifecycle_rules" {
  description = "Enable lifecycle rules to manage costs"
  type        = bool
  default     = true
}

variable "noncurrent_version_expiration_days" {
  description = "Days to keep noncurrent object versions before deletion"
  type        = number
  default     = 90
}

variable "object_expiration_days" {
  description = "Days to keep objects before deletion (0 = no expiration)"
  type        = number
  default     = 0

  validation {
    condition     = var.object_expiration_days >= 0
    error_message = "Object expiration days must be 0 or positive."
  }
}

variable "enable_glacier_transition" {
  description = "Enable transition to Glacier storage class (cheaper but not in free tier)"
  type        = bool
  default     = false
}

variable "glacier_transition_days" {
  description = "Days before transitioning to Glacier"
  type        = number
  default     = 90
}

variable "enable_intelligent_tiering" {
  description = "Enable Intelligent-Tiering storage class (automatic cost optimization)"
  type        = bool
  default     = false
}

variable "intelligent_tiering_days" {
  description = "Days before transitioning to Intelligent-Tiering"
  type        = number
  default     = 30
}

variable "logging_bucket" {
  description = "Target bucket for access logs (leave empty to disable logging)"
  type        = string
  default     = ""
}

variable "cors_rules" {
  description = "CORS rules for the bucket"
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = list(string)
    max_age_seconds = number
  }))
  default = []
}

variable "enable_website" {
  description = "Enable static website hosting"
  type        = bool
  default     = false
}

variable "website_index_document" {
  description = "Index document for website hosting"
  type        = string
  default     = "index.html"
}

variable "website_error_document" {
  description = "Error document for website hosting"
  type        = string
  default     = "error.html"
}

variable "enable_request_alarm" {
  description = "Enable CloudWatch alarm for request count"
  type        = bool
  default     = true
}

variable "request_alarm_threshold" {
  description = "Daily request threshold for alarm (free tier = 20k GET + 2k PUT per month)"
  type        = number
  default     = 600  # ~20k/month or 667/day, set lower for safety

  validation {
    condition     = var.request_alarm_threshold > 0
    error_message = "Request alarm threshold must be positive."
  }
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarms trigger (e.g., SNS topic ARNs)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
