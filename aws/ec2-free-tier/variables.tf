variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "free-tier-instance"
}

variable "instance_type" {
  description = "EC2 instance type (must be t2.micro or t3.micro for free tier)"
  type        = string
  default     = "t2.micro"

  validation {
    condition     = contains(["t2.micro", "t3.micro"], var.instance_type)
    error_message = "Instance type must be t2.micro or t3.micro to stay within free tier."
  }
}

variable "ami_id" {
  description = "AMI ID to use for the instance. Leave empty to use latest Amazon Linux 2"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "Name of the SSH key pair to use for the instance"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID where the instance will be launched"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be launched"
  type        = string
}

variable "root_volume_size" {
  description = "Size of the root volume in GB (free tier includes up to 30 GB)"
  type        = number
  default     = 8

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 30
    error_message = "Root volume size must be between 8 and 30 GB to stay within free tier."
  }
}

variable "root_volume_type" {
  description = "Type of root volume (gp2 or gp3 are free tier eligible)"
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3"], var.root_volume_type)
    error_message = "Root volume type must be gp2 or gp3 for free tier."
  }
}

variable "enable_encryption" {
  description = "Enable EBS encryption for the root volume"
  type        = bool
  default     = true
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring (5-minute intervals, within free tier)"
  type        = bool
  default     = false
}

variable "user_data" {
  description = "User data script to run on instance launch"
  type        = string
  default     = ""
}

variable "iam_instance_profile" {
  description = "IAM instance profile to attach to the instance"
  type        = string
  default     = ""
}

variable "ingress_rules" {
  description = "List of ingress rules for the security group"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      description = "SSH access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]  # WARNING: Restrict this in production!
    }
  ]
}

variable "assign_elastic_ip" {
  description = "Assign an Elastic IP to the instance (WARNING: unattached EIPs incur charges)"
  type        = bool
  default     = false
}

variable "enable_cpu_alarm" {
  description = "Enable CloudWatch alarm for high CPU utilization"
  type        = bool
  default     = true
}

variable "cpu_threshold" {
  description = "CPU utilization threshold percentage for alarm"
  type        = number
  default     = 80

  validation {
    condition     = var.cpu_threshold >= 0 && var.cpu_threshold <= 100
    error_message = "CPU threshold must be between 0 and 100."
  }
}

variable "enable_status_check_alarm" {
  description = "Enable CloudWatch alarm for instance status check failures"
  type        = bool
  default     = true
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarms trigger (e.g., SNS topic ARNs)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
