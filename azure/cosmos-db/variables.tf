variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "account_name" {
  description = "Cosmos DB account name (must be globally unique)"
  type        = string
}

variable "database_name" {
  description = "SQL database name"
  type        = string
  default     = "app-database"
}

variable "consistency_level" {
  description = "Consistency level for the Cosmos DB account"
  type        = string
  default     = "Session"

  validation {
    condition     = contains(["Strong", "BoundedStaleness", "Session", "ConsistentPrefix", "Eventual"], var.consistency_level)
    error_message = "consistency_level must be one of: Strong, BoundedStaleness, Session, ConsistentPrefix, Eventual."
  }
}

variable "throughput" {
  description = "Database throughput in RU/s. Max 1000 to stay within free tier"
  type        = number
  default     = 1000

  validation {
    condition     = var.throughput >= 400 && var.throughput <= 1000
    error_message = "throughput must be between 400 and 1000 RU/s to stay within the free tier."
  }
}

variable "containers" {
  description = "List of containers to create. Each container requires a name and partition_key_path. unique_keys is optional"
  type = list(object({
    name               = string
    partition_key_path = string
    unique_keys        = optional(list(list(string)), [])
  }))
  default = []
}

variable "enable_monitoring" {
  description = "Enable metric alerts for RU consumption and storage"
  type        = bool
  default     = false
}

variable "action_group_id" {
  description = "Action group ID for metric alert notifications"
  type        = string
  default     = ""
}

variable "ru_alert_threshold" {
  description = "RU consumption alert threshold percentage"
  type        = number
  default     = 80
}

variable "storage_alert_threshold_gb" {
  description = "Storage alert threshold in GB (max free tier is 25 GB)"
  type        = number
  default     = 20
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
