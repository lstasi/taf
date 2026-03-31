variable "queue_name" {
  description = "Name of the SQS queue. Append '.fifo' to create a FIFO queue"
  type        = string
  default     = "free-tier-queue"
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout (seconds) for messages in the queue. Range: 0–43200 (12 hours)"
  type        = number
  default     = 30

  validation {
    condition     = var.visibility_timeout_seconds >= 0 && var.visibility_timeout_seconds <= 43200
    error_message = "visibility_timeout_seconds must be between 0 and 43200."
  }
}

variable "message_retention_seconds" {
  description = "Time (seconds) that SQS retains a message. Range: 60 (1 min) – 1,209,600 (14 days)"
  type        = number
  default     = 345600 # 4 days

  validation {
    condition     = var.message_retention_seconds >= 60 && var.message_retention_seconds <= 1209600
    error_message = "message_retention_seconds must be between 60 and 1,209,600."
  }
}

variable "max_message_size" {
  description = "Maximum message size in bytes. Range: 1024 (1 KB) – 262144 (256 KB)"
  type        = number
  default     = 262144

  validation {
    condition     = var.max_message_size >= 1024 && var.max_message_size <= 262144
    error_message = "max_message_size must be between 1024 and 262144 bytes."
  }
}

variable "receive_wait_time_seconds" {
  description = "Long-polling wait time (seconds). Use 10–20 to reduce empty receives and stay within free tier"
  type        = number
  default     = 10

  validation {
    condition     = var.receive_wait_time_seconds >= 0 && var.receive_wait_time_seconds <= 20
    error_message = "receive_wait_time_seconds must be between 0 and 20."
  }
}

variable "delay_seconds" {
  description = "Delay (seconds) before delivering new messages to consumers. Range: 0–900"
  type        = number
  default     = 0

  validation {
    condition     = var.delay_seconds >= 0 && var.delay_seconds <= 900
    error_message = "delay_seconds must be between 0 and 900."
  }
}

variable "create_dead_letter_queue" {
  description = "Create a dead-letter queue (DLQ) for messages that fail processing"
  type        = bool
  default     = true
}

variable "max_receive_count" {
  description = "Number of times a consumer can receive a message before it is sent to the DLQ"
  type        = number
  default     = 5

  validation {
    condition     = var.max_receive_count >= 1
    error_message = "max_receive_count must be at least 1."
  }
}

variable "enable_encryption" {
  description = "Enable server-side encryption for the queue using the AWS-managed SQS key (free)"
  type        = bool
  default     = true
}

variable "create_cloudwatch_alarm" {
  description = "Create a CloudWatch alarm for queue depth"
  type        = bool
  default     = true
}

variable "alarm_depth_threshold" {
  description = "Number of messages in the queue that triggers the depth alarm"
  type        = number
  default     = 1000
}

variable "alarm_sns_topic_arn" {
  description = "ARN of the SNS topic to notify when alarms fire. Leave empty to skip"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
