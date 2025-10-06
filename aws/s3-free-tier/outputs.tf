output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.free_tier.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.free_tier.arn
}

output "bucket_domain_name" {
  description = "Domain name of the bucket"
  value       = aws_s3_bucket.free_tier.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the bucket"
  value       = aws_s3_bucket.free_tier.bucket_regional_domain_name
}

output "bucket_region" {
  description = "Region where the bucket is located"
  value       = aws_s3_bucket.free_tier.region
}

output "website_endpoint" {
  description = "Website endpoint (if website hosting is enabled)"
  value       = var.enable_website ? aws_s3_bucket_website_configuration.free_tier[0].website_endpoint : null
}

output "website_domain" {
  description = "Website domain (if website hosting is enabled)"
  value       = var.enable_website ? aws_s3_bucket_website_configuration.free_tier[0].website_domain : null
}

output "versioning_enabled" {
  description = "Whether versioning is enabled"
  value       = var.enable_versioning
}

output "free_tier_info" {
  description = "Information about free tier limits"
  value = {
    storage_limit_gb  = "5 GB for 12 months"
    get_requests      = "20,000 per month"
    put_requests      = "2,000 per month"
    data_transfer_out = "100 GB for 12 months"
  }
}
