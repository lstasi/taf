variable "tenancy_id" {
  description = "OCID of the OCI tenancy"
  type        = string
}

variable "compartment_id" {
  description = "OCID of the compartment for notifications"
  type        = string
}

variable "budget_name" {
  description = "Name of the OCI Budget"
  type        = string
  default     = "always-free-budget"
}

variable "monthly_threshold" {
  description = "Monthly cost threshold in USD"
  type        = number
  default     = 10.0
}

variable "warning_threshold" {
  description = "Warning threshold in USD (lower than monthly_threshold). Set to 0 to disable"
  type        = number
  default     = 5.0
}

variable "currency" {
  description = "Currency code for billing alerts"
  type        = string
  default     = "USD"
}

variable "email_address" {
  description = "Email address for alerts. Leave empty to skip"
  type        = string
  default     = ""
}

variable "https_endpoint" {
  description = "HTTPS webhook URL (e.g., Slack). Leave empty to skip"
  type        = string
  default     = ""
}

variable "freeform_tags" {
  description = "Freeform tags to apply to all resources"
  type        = map(string)
  default     = {}
}
