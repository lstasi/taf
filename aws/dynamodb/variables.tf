variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "hash_key" {
  description = "Attribute name used as the partition (hash) key"
  type        = string
}

variable "hash_key_type" {
  description = "Type of the hash key attribute: S (String), N (Number), or B (Binary)"
  type        = string
  default     = "S"

  validation {
    condition     = contains(["S", "N", "B"], var.hash_key_type)
    error_message = "hash_key_type must be S, N, or B."
  }
}

variable "range_key" {
  description = "Attribute name used as the sort (range) key. Leave empty for a simple table"
  type        = string
  default     = ""
}

variable "range_key_type" {
  description = "Type of the range key attribute: S (String), N (Number), or B (Binary)"
  type        = string
  default     = "S"

  validation {
    condition     = contains(["S", "N", "B"], var.range_key_type)
    error_message = "range_key_type must be S, N, or B."
  }
}

variable "read_capacity" {
  description = "Provisioned read capacity units (RCU). Always-free limit: 25 RCU total across all tables"
  type        = number
  default     = 5

  validation {
    condition     = var.read_capacity >= 1 && var.read_capacity <= 25
    error_message = "read_capacity must be between 1 and 25 to stay within the always-free tier."
  }
}

variable "write_capacity" {
  description = "Provisioned write capacity units (WCU). Always-free limit: 25 WCU total across all tables"
  type        = number
  default     = 5

  validation {
    condition     = var.write_capacity >= 1 && var.write_capacity <= 25
    error_message = "write_capacity must be between 1 and 25 to stay within the always-free tier."
  }
}

variable "ttl_attribute" {
  description = "Attribute name used for Time-to-Live (TTL) expiry. Leave empty to disable TTL"
  type        = string
  default     = ""
}

variable "global_secondary_indexes" {
  description = "List of global secondary index definitions"
  type = list(object({
    name               = string
    hash_key           = string
    hash_key_type      = optional(string, "S")
    range_key          = optional(string, "")
    range_key_type     = optional(string, "S")
    projection_type    = optional(string, "ALL")
    non_key_attributes = optional(list(string), [])
    read_capacity      = optional(number, 5)
    write_capacity     = optional(number, 5)
  }))
  default = []
}

variable "create_cloudwatch_alarm" {
  description = "Create CloudWatch alarms for consumed read and write capacity"
  type        = bool
  default     = true
}

variable "alarm_sns_topic_arn" {
  description = "ARN of the SNS topic to notify when capacity alarms fire. Leave empty to skip"
  type        = string
  default     = ""
}

variable "server_side_encryption" {
  description = "Enable server-side encryption using the AWS-managed DynamoDB key (free)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
