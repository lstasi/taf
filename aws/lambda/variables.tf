variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "description" {
  description = "Description of the Lambda function"
  type        = string
  default     = ""
}

variable "runtime" {
  description = "Lambda runtime identifier (e.g. python3.12, nodejs20.x, java21)"
  type        = string
  default     = "python3.12"
}

variable "handler" {
  description = "Function entrypoint in the format file.method (e.g. index.handler)"
  type        = string
  default     = "index.handler"
}

variable "filename" {
  description = "Path to the deployment package ZIP file. Mutually exclusive with s3_bucket/s3_key"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket containing the deployment package. Required when s3_key is set"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 key of the deployment package. Required when s3_bucket is set"
  type        = string
  default     = null
}

variable "source_code_hash" {
  description = "Base64-encoded SHA256 hash of the deployment package. Used to detect changes"
  type        = string
  default     = null
}

variable "memory_size" {
  description = "Amount of memory (in MB) allocated to the Lambda function. Min 128, max 10240"
  type        = number
  default     = 256

  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240
    error_message = "memory_size must be between 128 MB and 10240 MB."
  }
}

variable "timeout" {
  description = "Maximum execution time in seconds. Max 900 (15 minutes)"
  type        = number
  default     = 30

  validation {
    condition     = var.timeout >= 1 && var.timeout <= 900
    error_message = "timeout must be between 1 and 900 seconds."
  }
}

variable "environment_variables" {
  description = "Map of environment variables to pass to the Lambda function"
  type        = map(string)
  default     = {}
}

variable "iam_role_arn" {
  description = "ARN of an existing IAM role to assign to the Lambda function. If empty, a new role is created"
  type        = string
  default     = ""
}

variable "additional_policy_arns" {
  description = "List of additional IAM managed policy ARNs to attach to the auto-created IAM role"
  type        = list(string)
  default     = []
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days. Set to 0 to never expire logs"
  type        = number
  default     = 14
}

variable "create_cloudwatch_alarm" {
  description = "Create a CloudWatch alarm for function error rate"
  type        = bool
  default     = true
}

variable "alarm_error_threshold" {
  description = "Number of errors per evaluation period that triggers the alarm"
  type        = number
  default     = 5
}

variable "alarm_sns_topic_arn" {
  description = "ARN of the SNS topic to notify when the error alarm fires. Leave empty to skip"
  type        = string
  default     = ""
}

variable "schedule_expression" {
  description = "EventBridge schedule expression (e.g. rate(1 day) or cron(0 12 * * ? *)). Leave empty to skip"
  type        = string
  default     = ""
}

variable "reserved_concurrent_executions" {
  description = "Reserved concurrent executions for this function. -1 means unreserved"
  type        = number
  default     = -1
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
