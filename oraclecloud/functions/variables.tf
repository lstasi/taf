variable "compartment_id" {
  description = "OCID of the compartment"
  type        = string
}

variable "subnet_id" {
  description = "OCID of the subnet for function execution"
  type        = string
}

variable "application_display_name" {
  description = "Display name for the Function Application"
  type        = string
  default     = "free-tier-app"
}

variable "application_config" {
  description = "Configuration key/value map for the Function Application (available to all functions in the app)"
  type        = map(string)
  default     = {}
}

variable "functions" {
  description = "Map of function definitions to create within the application"
  type = map(object({
    image             = string
    memory_in_mbs     = optional(number, 256)
    timeout_in_seconds = optional(number, 30)  # Valid range: 1–300 seconds (max 5 minutes)
    config            = optional(map(string), {})
  }))
  default = {}
}

variable "create_api_gateway" {
  description = "Whether to create an OCI API Gateway for HTTP access to the functions (1M calls/month always free)"
  type        = bool
  default     = false
}

variable "api_gateway_subnet_id" {
  description = "OCID of the public subnet for the API Gateway (required when create_api_gateway = true)"
  type        = string
  default     = ""
}

variable "api_gateway_display_name" {
  description = "Display name for the API Gateway"
  type        = string
  default     = "free-api-gateway"
}

variable "api_routes" {
  description = "API Gateway routes mapping path to function key (key must match a key in var.functions)"
  type = map(object({
    function_key = string
    methods      = optional(list(string), ["GET", "POST"])
  }))
  default = {}
}

variable "notification_topic_id" {
  description = "OCID of the OCI Notifications topic for monitoring alarms. Leave empty to skip alarm creation"
  type        = string
  default     = ""
}

variable "freeform_tags" {
  description = "Freeform tags to apply to all resources"
  type        = map(string)
  default     = {}
}
