/**
 * AWS S3 Free Tier Module
 * 
 * Creates S3 buckets within AWS free tier limits:
 * - 5 GB of standard storage for 12 months
 * - 20,000 GET requests
 * - 2,000 PUT requests
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

# S3 bucket
resource "aws_s3_bucket" "free_tier" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = merge(
    var.tags,
    {
      Name      = var.bucket_name
      FreeTier  = "true"
      ManagedBy = "Terraform"
    }
  )
}

# Block public access (security best practice)
resource "aws_s3_bucket_public_access_block" "free_tier" {
  bucket = aws_s3_bucket.free_tier.id

  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "free_tier" {
  bucket = aws_s3_bucket.free_tier.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_id != "" ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_id != "" ? var.kms_key_id : null
    }
    bucket_key_enabled = var.kms_key_id != "" ? true : false
  }
}

# Versioning
resource "aws_s3_bucket_versioning" "free_tier" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.free_tier.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle rules to manage costs
resource "aws_s3_bucket_lifecycle_configuration" "free_tier" {
  count  = var.enable_lifecycle_rules ? 1 : 0
  bucket = aws_s3_bucket.free_tier.id

  rule {
    id     = "delete-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }
  }

  rule {
    id     = "expire-old-objects"
    status = var.object_expiration_days > 0 ? "Enabled" : "Disabled"

    expiration {
      days = var.object_expiration_days
    }
  }

  rule {
    id     = "transition-to-glacier"
    status = var.enable_glacier_transition ? "Enabled" : "Disabled"

    transition {
      days          = var.glacier_transition_days
      storage_class = "GLACIER"
    }
  }

  dynamic "rule" {
    for_each = var.enable_intelligent_tiering ? [1] : []
    content {
      id     = "intelligent-tiering"
      status = "Enabled"

      transition {
        days          = var.intelligent_tiering_days
        storage_class = "INTELLIGENT_TIERING"
      }
    }
  }
}

# Bucket logging (optional)
resource "aws_s3_bucket_logging" "free_tier" {
  count  = var.logging_bucket != "" ? 1 : 0
  bucket = aws_s3_bucket.free_tier.id

  target_bucket = var.logging_bucket
  target_prefix = "${var.bucket_name}/"
}

# CORS configuration (if needed)
resource "aws_s3_bucket_cors_configuration" "free_tier" {
  count  = length(var.cors_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.free_tier.id

  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

# Website configuration (optional)
resource "aws_s3_bucket_website_configuration" "free_tier" {
  count  = var.enable_website ? 1 : 0
  bucket = aws_s3_bucket.free_tier.id

  index_document {
    suffix = var.website_index_document
  }

  error_document {
    key = var.website_error_document
  }
}

# Bucket policy for website (if enabled)
resource "aws_s3_bucket_policy" "website" {
  count  = var.enable_website ? 1 : 0
  bucket = aws_s3_bucket.free_tier.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.free_tier.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.free_tier]
}

# CloudWatch metric alarm for request count (to monitor free tier usage)
resource "aws_cloudwatch_metric_alarm" "request_count" {
  count = var.enable_request_alarm ? 1 : 0

  alarm_name          = "${var.bucket_name}-high-requests"
  alarm_description   = "Alert when S3 requests approach free tier limits"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "AllRequests"
  namespace           = "AWS/S3"
  period              = 86400  # 1 day
  statistic           = "Sum"
  threshold           = var.request_alarm_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    BucketName = aws_s3_bucket.free_tier.id
  }

  alarm_actions = var.alarm_actions

  tags = merge(
    var.tags,
    {
      Name      = "${var.bucket_name}-requests"
      ManagedBy = "Terraform"
    }
  )
}
