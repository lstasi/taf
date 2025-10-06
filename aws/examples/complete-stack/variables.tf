variable "aws_region" {
  description = "AWS region (use us-east-1 for billing alarms)"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "taf-demo"
}

variable "unique_id" {
  description = "Unique identifier for globally unique names (e.g., AWS account ID or random string)"
  type        = string
}

variable "alert_email" {
  description = "Email address for billing alerts"
  type        = string
}

variable "lambda_zip_path" {
  description = "Path to Lambda deployment package (zip file)"
  type        = string
  default     = "./lambda/function.zip"
}

variable "enable_ec2" {
  description = "Whether to create an EC2 instance"
  type        = bool
  default     = false
}

variable "ssh_key_name" {
  description = "SSH key name for EC2 instance (required if enable_ec2 is true)"
  type        = string
  default     = ""
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed to SSH to EC2 instance"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
