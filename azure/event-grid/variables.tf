# ---------------------------------------------------------------------------
# Required variables
# ---------------------------------------------------------------------------

variable "resource_group_name" {
  description = "Name of the resource group to create for Event Grid resources."
  type        = string
}

variable "location" {
  description = "Azure region where the Event Grid resources will be deployed."
  type        = string
}

variable "topic_name" {
  description = "Name of the Event Grid custom topic."
  type        = string
}

# ---------------------------------------------------------------------------
# Topic configuration
# ---------------------------------------------------------------------------

variable "input_schema" {
  description = "Schema for incoming events. Determines how Event Grid interprets event payloads."
  type        = string
  default     = "EventGridSchema"

  validation {
    condition     = contains(["EventGridSchema", "CloudEventSchemaV1_0", "CustomInputSchema"], var.input_schema)
    error_message = "input_schema must be one of: EventGridSchema, CloudEventSchemaV1_0, CustomInputSchema."
  }
}

# ---------------------------------------------------------------------------
# Event subscriptions
# ---------------------------------------------------------------------------

variable "subscriptions" {
  description = "List of event subscriptions to create for the custom topic."
  type = list(object({
    name                  = string
    endpoint_type         = string
    endpoint_url          = string
    included_event_types  = optional(list(string), [])
    subject_filter_prefix = optional(string, "")
    subject_filter_suffix = optional(string, "")
    max_delivery_attempts = optional(number, 3)
    event_time_to_live    = optional(number, 1440)
  }))
  default = []
}

# ---------------------------------------------------------------------------
# Monitoring (optional)
# Always-free: 100,000 operations/month on Event Grid
# ---------------------------------------------------------------------------

variable "enable_monitoring" {
  description = "Whether to create metric alerts for Event Grid operations."
  type        = bool
  default     = false
}

variable "action_group_id" {
  description = "ID of the Azure Monitor action group for alert notifications. Required when enable_monitoring is true."
  type        = string
  default     = ""
}

variable "publish_alert_threshold" {
  description = "Threshold for the publish success count alert (80% of 100K free operations)."
  type        = number
  default     = 80000
}

# ---------------------------------------------------------------------------
# Tags
# ---------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
