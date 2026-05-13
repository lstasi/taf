# ─── OCI Authentication ────────────────────────────────────────────────────────

variable "tenancy_ocid" {
  description = "OCID of the OCI tenancy"
  type        = string
}

variable "user_ocid" {
  description = "OCID of the OCI user"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint for the OCI API key"
  type        = string
}

variable "private_key_path" {
  description = "Path to the OCI API private key PEM file"
  type        = string
}

variable "region" {
  description = "OCI region (e.g. eu-madrid-1)"
  type        = string
  default     = "eu-madrid-1"
}

# ─── Compartment ───────────────────────────────────────────────────────────────

variable "compartment_ocid" {
  description = "OCID of the compartment for all resources"
  type        = string
}

# ─── Compute ───────────────────────────────────────────────────────────────────

variable "availability_domain" {
  description = "Availability Domain name (e.g. from: oci iam availability-domain list)"
  type        = string
}

variable "image_id" {
  description = "OCID of the OS image. Must be for your region and the A1 (aarch64) platform. See: https://docs.oracle.com/en-us/iaas/images/"
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH key for instance access"
  type        = string
  sensitive   = true
}

variable "instance_ocpus" {
  description = "Number of OCPUs for A1.Flex. Tenancy-wide max is 4 across ALL A1 instances"
  type        = number
  default     = 1
}

variable "instance_memory_in_gbs" {
  description = "Memory in GB for A1.Flex. Tenancy-wide max is 24 GB across ALL A1 instances"
  type        = number
  default     = 6
}

variable "instance_display_name" {
  description = "Display name for the compute instance"
  type        = string
  default     = "openclaw-vm"
}

# ─── Billing alerts ────────────────────────────────────────────────────────────

variable "alert_email" {
  description = "Email address to receive billing alerts. Leave empty to skip email subscription"
  type        = string
  default     = ""
}

variable "monthly_threshold" {
  description = "Monthly spend threshold in USD that triggers an alert"
  type        = number
  default     = 10.0
}

# ─── Network ───────────────────────────────────────────────────────────────────

variable "ssh_ingress_cidr" {
  description = "CIDR allowed for SSH ingress. Use your specific operator IP (/32) — never 0.0.0.0/0"
  type        = string

  validation {
    condition     = var.ssh_ingress_cidr != "0.0.0.0/0"
    error_message = "ssh_ingress_cidr must not be 0.0.0.0/0. Use your operator IP, e.g. 1.2.3.4/32."
  }
}
