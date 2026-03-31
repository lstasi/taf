variable "topic_name" {
  description = "Name of the SNS topic. Append '.fifo' to create a FIFO topic"
  type        = string
  default     = "free-tier-topic"
}

variable "display_name" {
  description = "Display name for SMS notifications (max 10 characters)"
  type        = string
  default     = ""
}

variable "email_subscriptions" {
  description = "List of email addresses to subscribe to the topic. Always-free: 1,000 email deliveries/month"
  type        = list(string)
  default     = []
}

variable "https_subscriptions" {
  description = "List of HTTPS webhook URLs to subscribe to the topic. Always-free: 100,000 HTTP/S deliveries/month"
  type        = list(string)
  default     = []
}

variable "sqs_subscriptions" {
  description = "List of SQS queue ARNs to subscribe to the topic"
  type        = list(string)
  default     = []
}

variable "lambda_subscriptions" {
  description = "List of Lambda function ARNs to subscribe to the topic"
  type        = list(string)
  default     = []
}

variable "enable_encryption" {
  description = "Enable KMS encryption for the SNS topic using a new customer-managed key"
  type        = bool
  default     = false
}

variable "delivery_policy" {
  description = "JSON string for the SNS HTTP delivery policy. Leave empty to use AWS defaults"
  type        = string
  default     = ""
}

variable "create_cloudwatch_alarm" {
  description = "Create a CloudWatch alarm for failed notifications"
  type        = bool
  default     = false
}

variable "alarm_failure_threshold" {
  description = "Number of notification failures per evaluation period that triggers the alarm"
  type        = number
  default     = 10
}

variable "alarm_sns_topic_arn" {
  description = "ARN of a separate SNS topic to notify when the failure alarm fires. Leave empty to skip"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
