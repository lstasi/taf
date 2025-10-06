output "sns_topic_arn" {
  description = "ARN of the SNS topic for billing alerts"
  value       = aws_sns_topic.billing_alerts.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic"
  value       = aws_sns_topic.billing_alerts.name
}

output "billing_alarm_arn" {
  description = "ARN of the main billing CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.billing_alert.arn
}

output "billing_alarm_name" {
  description = "Name of the main billing alarm"
  value       = aws_cloudwatch_metric_alarm.billing_alert.alarm_name
}

output "warning_alarm_arn" {
  description = "ARN of the warning CloudWatch alarm (if created)"
  value       = var.warning_threshold > 0 ? aws_cloudwatch_metric_alarm.billing_warning[0].arn : null
}

output "warning_alarm_name" {
  description = "Name of the warning alarm (if created)"
  value       = var.warning_threshold > 0 ? aws_cloudwatch_metric_alarm.billing_warning[0].alarm_name : null
}

output "service_alarm_arns" {
  description = "Map of service names to their alarm ARNs"
  value       = { for k, v in aws_cloudwatch_metric_alarm.service_billing_alert : k => v.arn }
}

output "budget_id" {
  description = "ID of the AWS Budget (if created)"
  value       = var.create_budget ? aws_budgets_budget.monthly_cost[0].id : null
}

output "budget_name" {
  description = "Name of the AWS Budget (if created)"
  value       = var.create_budget ? aws_budgets_budget.monthly_cost[0].name : null
}

output "kms_key_id" {
  description = "ID of the KMS key used for SNS encryption (if enabled)"
  value       = var.enable_encryption ? aws_kms_key.sns[0].id : null
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for SNS encryption (if enabled)"
  value       = var.enable_encryption ? aws_kms_key.sns[0].arn : null
}
