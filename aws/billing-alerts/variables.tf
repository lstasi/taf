variable "alarm_name" {
  description = "Name of the CloudWatch billing alarm"
  type        = string
  default     = "billing-alert"
}

variable "monthly_threshold" {
  description = "Monthly cost threshold in dollars that triggers the alarm"
  type        = number
  default     = 10.0

  validation {
    condition     = var.monthly_threshold >= 0
    error_message = "Monthly threshold must be a positive number."
  }
}

variable "warning_threshold" {
  description = "Optional warning threshold (lower than monthly_threshold) for early alerts. Set to 0 to disable."
  type        = number
  default     = 5.0

  validation {
    condition     = var.warning_threshold >= 0
    error_message = "Warning threshold must be a positive number or 0 to disable."
  }
}

variable "currency" {
  description = "Currency code for billing alerts (USD, EUR, GBP, etc.)"
  type        = string
  default     = "USD"

  validation {
    condition     = contains(["USD", "EUR", "GBP", "CAD", "AUD", "JPY", "INR", "CNY"], var.currency)
    error_message = "Currency must be one of: USD, EUR, GBP, CAD, AUD, JPY, INR, CNY."
  }
}

variable "email_address" {
  description = "Email address to receive billing alerts. Leave empty to skip email subscription."
  type        = string
  default     = ""

  validation {
    condition     = var.email_address == "" || can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.email_address))
    error_message = "Email address must be valid or empty."
  }
}

variable "sms_number" {
  description = "SMS phone number to receive alerts (E.164 format, e.g., +1234567890). Leave empty to skip SMS."
  type        = string
  default     = ""

  validation {
    condition     = var.sms_number == "" || can(regex("^\\+[1-9]\\d{1,14}$", var.sms_number))
    error_message = "SMS number must be in E.164 format (e.g., +1234567890) or empty."
  }
}

variable "https_endpoint" {
  description = "HTTPS endpoint URL to receive alerts (webhook). Leave empty to skip HTTPS subscription."
  type        = string
  default     = ""

  validation {
    condition     = var.https_endpoint == "" || can(regex("^https://", var.https_endpoint))
    error_message = "HTTPS endpoint must start with https:// or be empty."
  }
}

variable "sns_topic_name" {
  description = "Name of the SNS topic for billing alerts"
  type        = string
  default     = "billing-alerts-topic"
}

variable "send_ok_notifications" {
  description = "Whether to send notifications when alarm returns to OK state"
  type        = bool
  default     = false
}

variable "enable_encryption" {
  description = "Enable KMS encryption for SNS topic"
  type        = bool
  default     = false
}

variable "create_budget" {
  description = "Create an AWS Budget in addition to CloudWatch alarms"
  type        = bool
  default     = true
}

variable "budget_name" {
  description = "Name of the AWS Budget"
  type        = string
  default     = "monthly-cost-budget"
}

variable "service_thresholds" {
  description = "Map of AWS service names to their cost thresholds. Creates separate alarms per service."
  type        = map(number)
  default     = {}

  # Example:
  # service_thresholds = {
  #   "Amazon Elastic Compute Cloud - Compute" = 5.0
  #   "Amazon Simple Storage Service"          = 2.0
  #   "Amazon Relational Database Service"     = 3.0
  # }
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
