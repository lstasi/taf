/**
 * Complete AWS Free Tier Stack Example
 * 
 * This example demonstrates how to use multiple free tier modules together
 * to create a complete serverless application with billing protection.
 */

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider configuration - us-east-1 required for billing alarms
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "terraform-always-free"
      Environment = "free-tier"
      ManagedBy   = "Terraform"
    }
  }
}

# Get default VPC (free tier)
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 1. BILLING ALERTS (Deploy this first!)
module "billing_alerts" {
  source = "../../billing-alerts"

  email_address     = var.alert_email
  monthly_threshold = 10.0
  warning_threshold = 5.0
  currency          = "USD"

  # Per-service thresholds
  service_thresholds = {
    "Amazon Elastic Compute Cloud - Compute" = 5.0
    "Amazon Simple Storage Service"          = 2.0
    "AWS Lambda"                             = 1.0
  }

  tags = {
    Priority = "Critical"
  }
}

# 2. S3 BUCKET for static website and file storage
module "website_bucket" {
  source = "../../s3-free-tier"

  bucket_name         = "${var.project_name}-website-${var.unique_id}"
  block_public_access = false  # Allow public access for website
  enable_website      = true

  # Lifecycle rules to stay within free tier
  enable_lifecycle_rules = true
  object_expiration_days = 365  # Auto-delete old files

  # Monitoring
  enable_request_alarm    = true
  request_alarm_threshold = 500
  alarm_actions           = [module.billing_alerts.sns_topic_arn]

  tags = {
    Purpose = "StaticWebsite"
  }
}

# 3. LAMBDA FUNCTION for API backend
module "api_function" {
  source = "../../lambda-free-tier"

  function_name = "${var.project_name}-api"
  filename      = var.lambda_zip_path
  handler       = "index.handler"
  runtime       = "python3.11"
  timeout       = 10
  memory_size   = 128

  # Environment configuration
  environment_variables = {
    BUCKET_NAME = module.website_bucket.bucket_id
    TABLE_NAME  = "free-tier-data"
  }

  # Enable public HTTP endpoint
  enable_function_url    = true
  function_url_auth_type = "NONE"

  function_url_cors = {
    allow_credentials = false
    allow_headers     = ["content-type"]
    allow_methods     = ["GET", "POST"]
    allow_origins     = ["*"]
    expose_headers    = []
    max_age           = 3600
  }

  # Monitoring
  enable_error_alarm      = true
  enable_throttle_alarm   = true
  enable_invocation_alarm = true
  alarm_actions           = [module.billing_alerts.sns_topic_arn]

  # Logging
  log_retention_days = 7

  # S3 access
  additional_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  tags = {
    Purpose = "API"
  }
}

# 4. EC2 INSTANCE (optional - for development/testing)
module "dev_instance" {
  count  = var.enable_ec2 ? 1 : 0
  source = "../../ec2-free-tier"

  instance_name = "${var.project_name}-dev"
  instance_type = "t2.micro"
  vpc_id        = data.aws_vpc.default.id
  subnet_id     = data.aws_subnets.default.ids[0]
  key_name      = var.ssh_key_name

  # Security - SSH from specific IP only
  ingress_rules = [
    {
      description = "SSH from my IP"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.allowed_ssh_cidr
    },
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  # Storage
  root_volume_size  = 8
  root_volume_type  = "gp3"
  enable_encryption = true

  # Monitoring
  enable_cpu_alarm          = true
  enable_status_check_alarm = true
  alarm_actions             = [module.billing_alerts.sns_topic_arn]

  # User data - install web server
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from AWS Free Tier!</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Purpose = "Development"
  }
}

# 5. ADDITIONAL S3 BUCKET for Lambda data
module "data_bucket" {
  source = "../../s3-free-tier"

  bucket_name = "${var.project_name}-data-${var.unique_id}"

  # Security
  block_public_access = true
  enable_encryption   = true

  # Lifecycle
  enable_lifecycle_rules             = true
  noncurrent_version_expiration_days = 30

  # Monitoring
  enable_request_alarm = true
  alarm_actions        = [module.billing_alerts.sns_topic_arn]

  tags = {
    Purpose = "DataStorage"
  }
}

# Lambda permission for S3 to invoke function
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = module.api_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = module.data_bucket.bucket_arn
}

# S3 bucket notification to trigger Lambda
resource "aws_s3_bucket_notification" "data_upload" {
  bucket = module.data_bucket.bucket_id

  lambda_function {
    lambda_function_arn = module.api_function.function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "uploads/"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
