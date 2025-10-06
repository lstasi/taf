output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.free_tier.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.free_tier.arn
}

output "function_qualified_arn" {
  description = "Qualified ARN of the Lambda function"
  value       = aws_lambda_function.free_tier.qualified_arn
}

output "function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.free_tier.invoke_arn
}

output "function_url" {
  description = "URL of the Lambda function (if function URL is enabled)"
  value       = var.enable_function_url ? aws_lambda_function_url.free_tier[0].function_url : null
}

output "function_version" {
  description = "Latest published version of the Lambda function"
  value       = aws_lambda_function.free_tier.version
}

output "role_arn" {
  description = "ARN of the IAM role for the Lambda function"
  value       = aws_iam_role.lambda.arn
}

output "role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.lambda.name
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda.arn
}

output "free_tier_info" {
  description = "Information about Lambda free tier limits"
  value = {
    monthly_requests        = "1,000,000 (always free)"
    compute_time_gb_seconds = "400,000 (always free)"
    daily_requests_safe     = "~25,000 (with safety margin)"
    memory_note            = "Higher memory = faster but uses more GB-seconds"
  }
}
