variable "region" {
  description = "OCI region identifier (e.g., 'us-ashburn-1'). Used to construct object storage URLs"
  type        = string
}

variable "compartment_id" {
  description = "OCID of the compartment"
  type        = string
}

variable "bucket_name" {
  description = "Name of the Object Storage bucket"
  type        = string
}

variable "storage_tier" {
  description = "Storage tier: 'Standard' (always-free: 20 GB) or 'Archive' (always-free: 10 GB)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Archive"], var.storage_tier)
    error_message = "storage_tier must be 'Standard' or 'Archive'. Infrequent Access is not in the always-free tier."
  }
}

variable "access_type" {
  description = "Bucket access type: 'NoPublicAccess', 'ObjectRead', or 'ObjectReadWithoutList'"
  type        = string
  default     = "NoPublicAccess"

  validation {
    condition     = contains(["NoPublicAccess", "ObjectRead", "ObjectReadWithoutList"], var.access_type)
    error_message = "access_type must be one of: NoPublicAccess, ObjectRead, ObjectReadWithoutList."
  }
}

variable "versioning" {
  description = "Object versioning: 'Enabled' or 'Disabled'. Disable to avoid extra storage usage"
  type        = string
  default     = "Disabled"

  validation {
    condition     = contains(["Enabled", "Disabled"], var.versioning)
    error_message = "versioning must be 'Enabled' or 'Disabled'."
  }
}

variable "enable_lifecycle_policy" {
  description = "Whether to create a lifecycle policy to manage object retention"
  type        = bool
  default     = false
}

variable "lifecycle_archive_days" {
  description = "Days after which Standard objects are moved to Archive (requires enable_lifecycle_policy = true)"
  type        = number
  default     = 30
}

variable "lifecycle_delete_days" {
  description = "Days after which objects are deleted (requires enable_lifecycle_policy = true). 0 to disable delete rule"
  type        = number
  default     = 365
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
