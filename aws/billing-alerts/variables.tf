variable "alarm_name" {
  description = "Name prefix for the CloudWatch billing alarms"
  type        = string
  default     = "billing-alert"
}

variable "monthly_threshold" {
  description = "Monthly cost threshold in USD. Alarm triggers when estimated charges exceed this value"
  type        = number
  default     = 10.0
}

variable "warning_threshold" {
  description = "Warning threshold in USD (should be lower than monthly_threshold). Set to 0 to disable"
  type        = number
  default     = 5.0
}

variable "currency" {
  description = "Currency code for billing alerts"
  type        = string
  default     = "USD"
}

variable "email_address" {
  description = "Email address for billing alert notifications. Leave empty to skip email subscription"
  type        = string
  default     = ""
}

variable "sms_number" {
  description = "SMS phone number in E.164 format (e.g. +12065550101). Leave empty to skip SMS subscription"
  type        = string
  default     = ""
}

variable "https_endpoint" {
  description = "HTTPS webhook URL (e.g. Slack incoming webhook). Leave empty to skip HTTPS subscription"
  type        = string
  default     = ""
}

variable "sns_topic_name" {
  description = "Name of the SNS topic created for billing alert notifications"
  type        = string
  default     = "billing-alerts-topic"
}

variable "send_ok_notifications" {
  description = "Send an SNS notification when the billing alarm returns to OK state"
  type        = bool
  default     = false
}

variable "enable_encryption" {
  description = "Enable KMS encryption for the SNS topic (uses a new customer-managed key)"
  type        = bool
  default     = false
}

variable "create_budget" {
  description = "Create an AWS Budget with cost thresholds and notifications"
  type        = bool
  default     = true
}

variable "budget_name" {
  description = "Name of the AWS Budget"
  type        = string
  default     = "monthly-cost-budget"
}

variable "service_thresholds" {
  description = "Map of AWS service names to individual monthly cost thresholds (USD). Creates one CloudWatch alarm per service"
  type        = map(number)
  default     = {}
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
