variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "function_app_name" {
  description = "Name of the function app"
  type        = string
}

variable "storage_account_name" {
  description = "Storage account name (must be globally unique, 3-24 chars, lowercase alphanumeric only)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "storage_account_name must be 3-24 characters, lowercase letters and numbers only."
  }
}

variable "os_type" {
  description = "Operating system type for the function app"
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "os_type must be either Linux or Windows."
  }
}

variable "runtime" {
  description = "Function runtime stack"
  type        = string
  default     = "node"

  validation {
    condition     = contains(["node", "python", "dotnet", "java", "powershell"], var.runtime)
    error_message = "runtime must be one of: node, python, dotnet, java, powershell."
  }
}

variable "runtime_version" {
  description = "Runtime version (e.g. 18 for Node.js, 3.10 for Python)"
  type        = string
  default     = "18"
}

variable "app_settings" {
  description = "Additional app settings for the function app"
  type        = map(string)
  default     = {}
}

variable "enable_monitoring" {
  description = "Enable metric alerts for function execution count"
  type        = bool
  default     = false
}

variable "action_group_id" {
  description = "Action group ID for metric alert notifications"
  type        = string
  default     = ""
}

variable "execution_alert_threshold" {
  description = "Execution count alert threshold (90% of 1M free tier limit)"
  type        = number
  default     = 900000
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
