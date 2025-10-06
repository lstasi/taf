output "billing_alert_topic" {
  description = "SNS topic ARN for billing alerts"
  value       = module.billing_alerts.sns_topic_arn
}

output "website_url" {
  description = "Static website URL"
  value       = "http://${module.website_bucket.website_endpoint}"
}

output "website_bucket" {
  description = "Website S3 bucket name"
  value       = module.website_bucket.bucket_id
}

output "api_url" {
  description = "Lambda function URL for API"
  value       = module.api_function.function_url
}

output "api_function_name" {
  description = "Lambda function name"
  value       = module.api_function.function_name
}

output "data_bucket" {
  description = "Data storage bucket name"
  value       = module.data_bucket.bucket_id
}

output "ec2_instance_id" {
  description = "EC2 instance ID (if created)"
  value       = var.enable_ec2 ? module.dev_instance[0].instance_id : null
}

output "ec2_public_ip" {
  description = "EC2 public IP (if created)"
  value       = var.enable_ec2 ? module.dev_instance[0].public_ip : null
}

output "ec2_ssh_command" {
  description = "SSH command to connect to EC2 (if created)"
  value       = var.enable_ec2 ? module.dev_instance[0].ssh_command : null
}

output "next_steps" {
  description = "Next steps to complete the setup"
  value = <<-EOT
    
    🎉 Deployment Complete!
    
    Next steps:
    
    1. Confirm SNS subscription:
       - Check your email (${var.alert_email})
       - Click the confirmation link
    
    2. Upload website files:
       aws s3 cp index.html s3://${module.website_bucket.bucket_id}/
       aws s3 cp error.html s3://${module.website_bucket.bucket_id}/
    
    3. Access your website:
       http://${module.website_bucket.website_endpoint}
    
    4. Test your API:
       curl ${module.api_function.function_url}
    
    5. Monitor costs:
       - AWS Cost Explorer: https://console.aws.amazon.com/cost-management/
       - CloudWatch Alarms: https://console.aws.amazon.com/cloudwatch/
    
    ${var.enable_ec2 ? "6. Connect to EC2:\n       ${module.dev_instance[0].ssh_command}\n" : ""}
    
    ⚠️  Remember:
    - Stay within free tier limits
    - Monitor CloudWatch alarms
    - Review costs weekly
    
  EOT
}
