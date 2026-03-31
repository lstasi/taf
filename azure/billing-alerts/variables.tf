variable "resource_group_name" {
  description = "Name of the resource group to create for billing alert resources"
  type        = string
}

variable "location" {
  description = "Azure region for the resource group"
  type        = string
}

variable "budget_name" {
  description = "Name of the consumption budget"
  type        = string
  default     = "monthly-budget"
}

variable "monthly_budget" {
  description = "Monthly budget amount. Alerts trigger at the configured threshold percentages of this value"
  type        = number
  default     = 10.0
}

variable "warning_threshold" {
  description = "Warning threshold amount in the configured currency (should be lower than monthly_budget)"
  type        = number
  default     = 5.0
}

variable "currency" {
  description = "Currency code for budget alerts"
  type        = string
  default     = "USD"
}

variable "email_addresses" {
  description = "List of email addresses to receive billing alert notifications"
  type        = list(string)
  default     = []
}

variable "webhook_url" {
  description = "Webhook URL for billing alert notifications. Leave empty to skip webhook receiver"
  type        = string
  default     = ""
}

variable "alert_thresholds" {
  description = "List of alert threshold configurations for the budget. Each object defines a percentage threshold and whether it is based on actual or forecasted spend"
  type = list(object({
    threshold = number
    type      = string
  }))
  default = [
    { threshold = 50, type = "Actual" },
    { threshold = 80, type = "Actual" },
    { threshold = 100, type = "Forecasted" },
  ]
}

variable "enable_anomaly_alerts" {
  description = "Create a Cost Anomaly Alert to detect unexpected spending patterns"
  type        = bool
  default     = true
}

variable "budget_start_date" {
  description = "Start date for the budget time period in RFC 3339 format"
  type        = string
  default     = "2024-01-01T00:00:00Z"
}

variable "budget_end_date" {
  description = "End date for the budget time period in RFC 3339 format"
  type        = string
  default     = "2025-12-31T23:59:59Z"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
