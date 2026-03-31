variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
}

variable "namespace_name" {
  description = "Service Bus namespace name (must be globally unique)"
  type        = string
}

variable "queues" {
  description = "List of queues to create in the Service Bus namespace"
  type = list(object({
    name                                 = string
    default_message_ttl                  = optional(string, "P7D")
    lock_duration                        = optional(string, "PT1M")
    max_delivery_count                   = optional(number, 5)
    max_size_in_megabytes                = optional(number, 1024)
    dead_lettering_on_message_expiration = optional(bool, true)
  }))
  default = []
}

variable "create_authorization_rules" {
  description = "Create separate sender/listener authorization rules for each queue"
  type        = bool
  default     = false
}

variable "enable_monitoring" {
  description = "Enable Azure Monitor metric alerts for queues"
  type        = bool
  default     = false
}

variable "action_group_id" {
  description = "Action group ID for alert notifications"
  type        = string
  default     = ""
}

variable "queue_depth_alert_threshold" {
  description = "Alert when active messages in a queue exceed this count"
  type        = number
  default     = 1000
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
