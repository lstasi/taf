variable "compartment_id" {
  description = "OCID of the compartment"
  type        = string
}

variable "availability_domain" {
  description = "Availability Domain name (e.g., from data.oci_identity_availability_domains)"
  type        = string
}

variable "subnet_id" {
  description = "OCID of the subnet to place the instance in"
  type        = string
}

variable "image_id" {
  description = "OCID of the OS image to use for the instance"
  type        = string
}

variable "shape" {
  description = "Instance shape. Use 'VM.Standard.A1.Flex' (ARM, always-free) or 'VM.Standard.E2.1.Micro' (AMD, always-free)"
  type        = string
  default     = "VM.Standard.A1.Flex"

  validation {
    condition     = contains(["VM.Standard.A1.Flex", "VM.Standard.E2.1.Micro"], var.shape)
    error_message = "Only always-free shapes are allowed: VM.Standard.A1.Flex or VM.Standard.E2.1.Micro."
  }
}

variable "ocpus" {
  description = "Number of OCPUs for VM.Standard.A1.Flex (max 4 across all A1 instances). Ignored for E2.1.Micro"
  type        = number
  default     = 1

  validation {
    condition     = var.ocpus >= 1 && var.ocpus <= 4
    error_message = "OCPUs must be between 1 and 4 for always-free A1.Flex."
  }
}

variable "memory_in_gbs" {
  description = "Memory in GB for VM.Standard.A1.Flex (max 24 GB across all A1 instances). Ignored for E2.1.Micro"
  type        = number
  default     = 6

  validation {
    condition     = var.memory_in_gbs >= 1 && var.memory_in_gbs <= 24
    error_message = "Memory must be between 1 GB and 24 GB for always-free A1.Flex."
  }
}

variable "boot_volume_size_in_gbs" {
  description = "Size of the boot volume in GB. Total block storage across all instances must stay under 200 GB"
  type        = number
  default     = 50
}

variable "assign_public_ip" {
  description = "Whether to assign an ephemeral public IP to the instance (always free)"
  type        = bool
  default     = true
}

variable "ssh_authorized_keys" {
  description = "Public SSH key(s) authorized to connect to the instance"
  type        = string
  sensitive   = true
}

variable "user_data" {
  description = "Base64-encoded cloud-init user data script"
  type        = string
  default     = ""
}

variable "display_name" {
  description = "Display name for the instance"
  type        = string
  default     = "free-instance"
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
