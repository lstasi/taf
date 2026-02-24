variable "compartment_id" {
  description = "OCID of the compartment"
  type        = string
}

variable "db_name" {
  description = "Database name (1-14 characters, letters and numbers only, must start with a letter)"
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9]{0,13}$", var.db_name))
    error_message = "db_name must be 1-14 alphanumeric characters starting with a letter."
  }
}

variable "display_name" {
  description = "Display name for the Autonomous Database"
  type        = string
  default     = ""
}

variable "db_workload" {
  description = "Workload type: OLTP (ATP), DW (ADW), or AJD (Autonomous JSON Database)"
  type        = string
  default     = "OLTP"

  validation {
    condition     = contains(["OLTP", "DW", "AJD", "APEX"], var.db_workload)
    error_message = "db_workload must be one of: OLTP, DW, AJD, APEX."
  }
}

variable "admin_password" {
  description = "Admin password for the Autonomous Database (min 12 chars, must include uppercase, number, and special character)"
  type        = string
  sensitive   = true
}

variable "whitelisted_ips" {
  description = "List of IP addresses or CIDR blocks allowed to connect. Leave empty to allow all"
  type        = list(string)
  default     = []
}

variable "is_auto_scaling_enabled" {
  description = "Whether to enable auto-scaling. Must be false for always-free tier"
  type        = bool
  default     = false
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
