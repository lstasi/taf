variable "name" {
  description = "Name of the Step Functions state machine"
  type        = string
}

variable "definition" {
  description = "Amazon States Language (ASL) JSON definition of the state machine"
  type        = string
}

variable "iam_role_arn" {
  description = "ARN of an existing IAM role for the state machine. If empty, a new role is created"
  type        = string
  default     = ""
}

variable "additional_policy_arns" {
  description = "List of IAM managed policy ARNs to attach to the auto-created IAM role"
  type        = list(string)
  default     = []
}

variable "lambda_arns" {
  description = "List of Lambda function ARNs that the state machine is allowed to invoke"
  type        = list(string)
  default     = []
}

variable "dynamodb_table_arns" {
  description = "List of DynamoDB table ARNs that the state machine is allowed to read/write"
  type        = list(string)
  default     = []
}

variable "sns_topic_arns" {
  description = "List of SNS topic ARNs that the state machine is allowed to publish to"
  type        = list(string)
  default     = []
}

variable "sqs_queue_arns" {
  description = "List of SQS queue ARNs that the state machine is allowed to send messages to"
  type        = list(string)
  default     = []
}

variable "enable_logging" {
  description = "Enable CloudWatch Logs execution logging for the state machine"
  type        = bool
  default     = true
}

variable "log_level" {
  description = "Log level for execution logging: OFF, ALL, ERROR, or FATAL"
  type        = string
  default     = "ERROR"

  validation {
    condition     = contains(["OFF", "ALL", "ERROR", "FATAL"], var.log_level)
    error_message = "log_level must be one of: OFF, ALL, ERROR, FATAL."
  }
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days for execution logs"
  type        = number
  default     = 14
}

variable "create_cloudwatch_alarm" {
  description = "Create a CloudWatch alarm for failed executions"
  type        = bool
  default     = true
}

variable "alarm_failure_threshold" {
  description = "Number of failed executions per evaluation period that triggers the alarm"
  type        = number
  default     = 1
}

variable "alarm_sns_topic_arn" {
  description = "ARN of the SNS topic to notify when the failure alarm fires. Leave empty to skip"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
