output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.main.arn
}

output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.main.function_name
}

output "function_invoke_arn" {
  description = "Invoke ARN of the Lambda function (used for API Gateway integrations)"
  value       = aws_lambda_function.main.invoke_arn
}

output "qualified_arn" {
  description = "Qualified ARN (including version) of the Lambda function"
  value       = aws_lambda_function.main.qualified_arn
}

output "iam_role_arn" {
  description = "ARN of the IAM role attached to the Lambda function"
  value       = local.effective_role
}

output "iam_role_name" {
  description = "Name of the auto-created IAM role (empty if an existing role was provided)"
  value       = var.iam_role_arn == "" ? aws_iam_role.lambda[0].name : ""
}

output "log_group_name" {
  description = "Name of the CloudWatch log group for the Lambda function"
  value       = aws_cloudwatch_log_group.lambda.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group for the Lambda function"
  value       = aws_cloudwatch_log_group.lambda.arn
}

output "error_alarm_arn" {
  description = "ARN of the CloudWatch error alarm (empty if create_cloudwatch_alarm = false)"
  value       = var.create_cloudwatch_alarm ? aws_cloudwatch_metric_alarm.errors[0].arn : ""
}

output "schedule_rule_arn" {
  description = "ARN of the EventBridge schedule rule (empty if schedule_expression is not set)"
  value       = var.schedule_expression != "" ? aws_cloudwatch_event_rule.schedule[0].arn : ""
}
