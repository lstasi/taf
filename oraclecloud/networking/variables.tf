variable "compartment_id" {
  description = "OCID of the compartment"
  type        = string
}

variable "vcn_cidr" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vcn_display_name" {
  description = "Display name for the VCN"
  type        = string
  default     = "main-vcn"
}

variable "vcn_dns_label" {
  description = "DNS label for the VCN (lowercase letters and numbers only)"
  type        = string
  default     = "mainvcn"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "create_load_balancer" {
  description = "Whether to create the always-free flexible load balancer (10 Mbps)"
  type        = bool
  default     = true
}

variable "ssh_ingress_cidr" {
  description = "CIDR block allowed for SSH ingress on the public subnet. Use a specific IP (/32) for security"
  type        = string
  default     = "0.0.0.0/0"
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
