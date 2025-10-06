terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure AWS Provider - Must use us-east-1 for billing alarms
provider "aws" {
  region = "us-east-1"
}

# Basic billing alerts with email notification
module "billing_alerts" {
  source = "../../"

  email_address     = "your-email@example.com"  # Change this!
  monthly_threshold = 10.0
  warning_threshold = 5.0
  currency          = "USD"

  tags = {
    Environment = "free-tier"
    Purpose     = "cost-monitoring"
  }
}

# Outputs
output "sns_topic_arn" {
  description = "SNS topic ARN for billing alerts"
  value       = module.billing_alerts.sns_topic_arn
}

output "alarm_name" {
  description = "CloudWatch alarm name"
  value       = module.billing_alerts.billing_alarm_name
}
