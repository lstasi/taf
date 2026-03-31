variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "namespace_name" {
  description = "Notification Hub namespace name (must be globally unique)"
  type        = string
}

variable "hub_name" {
  description = "Notification Hub name"
  type        = string
}

variable "apns_credential" {
  description = "Apple Push Notification Service (APNs) token-based credential"
  type = object({
    application_mode = string
    bundle_id        = string
    key_id           = string
    team_id          = string
    token            = string
  })
  default = null
}

variable "gcm_credential" {
  description = "Firebase Cloud Messaging (FCM/GCM) credential"
  type = object({
    api_key = string
  })
  default = null
}

variable "create_listen_rule" {
  description = "Create a listen-only authorization rule for client applications"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
