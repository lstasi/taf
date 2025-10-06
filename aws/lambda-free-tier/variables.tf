variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "filename" {
  description = "Path to the function's deployment package (zip file). Conflicts with s3_* variables."
  type        = string
  default     = ""
}

variable "s3_bucket" {
  description = "S3 bucket where the function's deployment package is stored"
  type        = string
  default     = ""
}

variable "s3_key" {
  description = "S3 key of the function's deployment package"
  type        = string
  default     = ""
}

variable "s3_object_version" {
  description = "S3 object version of the function's deployment package"
  type        = string
  default     = ""
}

variable "handler" {
  description = "Function entrypoint in your code"
  type        = string
  default     = "index.handler"
}

variable "runtime" {
  description = "Lambda runtime (e.g., python3.11, nodejs20.x, etc.)"
  type        = string
  default     = "python3.11"

  validation {
    condition = contains([
      "nodejs18.x", "nodejs20.x",
      "python3.9", "python3.10", "python3.11", "python3.12",
      "java11", "java17", "java21",
      "dotnet6", "dotnet8",
      "go1.x",
      "ruby3.2", "ruby3.3"
    ], var.runtime)
    error_message = "Runtime must be a supported Lambda runtime."
  }
}

variable "timeout" {
  description = "Function timeout in seconds (max 900 for Lambda)"
  type        = number
  default     = 3

  validation {
    condition     = var.timeout >= 1 && var.timeout <= 900
    error_message = "Timeout must be between 1 and 900 seconds."
  }
}

variable "memory_size" {
  description = "Amount of memory in MB (128-10240). Higher memory = more compute power and cost."
  type        = number
  default     = 128

  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240
    error_message = "Memory size must be between 128 and 10240 MB."
  }
}

variable "reserved_concurrent_executions" {
  description = "Reserved concurrent executions for this function. -1 = unreserved, 0 = disable function"
  type        = number
  default     = -1

  validation {
    condition     = var.reserved_concurrent_executions >= -1
    error_message = "Reserved concurrent executions must be -1 or greater."
  }
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "vpc_config" {
  description = "VPC configuration for the Lambda function (NOTE: VPC functions use NAT Gateway which costs money)"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "dead_letter_target_arn" {
  description = "ARN of SNS topic or SQS queue for failed invocations"
  type        = string
  default     = ""
}

variable "enable_xray_tracing" {
  description = "Enable AWS X-Ray tracing"
  type        = bool
  default     = false
}

variable "enable_function_url" {
  description = "Enable Lambda function URL (HTTP endpoint)"
  type        = bool
  default     = false
}

variable "function_url_auth_type" {
  description = "Authorization type for function URL (NONE or AWS_IAM)"
  type        = string
  default     = "AWS_IAM"

  validation {
    condition     = contains(["NONE", "AWS_IAM"], var.function_url_auth_type)
    error_message = "Function URL auth type must be NONE or AWS_IAM."
  }
}

variable "function_url_cors" {
  description = "CORS configuration for function URL"
  type = object({
    allow_credentials = bool
    allow_headers     = list(string)
    allow_methods     = list(string)
    allow_origins     = list(string)
    expose_headers    = list(string)
    max_age           = number
  })
  default = null
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7

  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653
    ], var.log_retention_days)
    error_message = "Log retention must be a valid CloudWatch Logs retention value."
  }
}

variable "log_kms_key_id" {
  description = "KMS key ID for CloudWatch log encryption"
  type        = string
  default     = ""
}

variable "additional_policy_arns" {
  description = "List of additional IAM policy ARNs to attach to the Lambda role"
  type        = list(string)
  default     = []
}

variable "enable_error_alarm" {
  description = "Enable CloudWatch alarm for function errors"
  type        = bool
  default     = true
}

variable "error_threshold" {
  description = "Number of errors to trigger alarm"
  type        = number
  default     = 5
}

variable "enable_throttle_alarm" {
  description = "Enable CloudWatch alarm for function throttles"
  type        = bool
  default     = true
}

variable "enable_invocation_alarm" {
  description = "Enable CloudWatch alarm for high invocation count"
  type        = bool
  default     = true
}

variable "daily_invocation_threshold" {
  description = "Daily invocation threshold for alarm (free tier = 1M/month or ~33k/day)"
  type        = number
  default     = 25000  # Set lower for safety margin

  validation {
    condition     = var.daily_invocation_threshold > 0
    error_message = "Daily invocation threshold must be positive."
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
