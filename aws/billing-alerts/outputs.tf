output "sns_topic_arn" {
  description = "ARN of the SNS topic used for billing alert notifications"
  value       = aws_sns_topic.billing.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic used for billing alert notifications"
  value       = aws_sns_topic.billing.name
}

output "billing_alarm_arn" {
  description = "ARN of the main CloudWatch billing alarm"
  value       = aws_cloudwatch_metric_alarm.billing.arn
}

output "billing_alarm_name" {
  description = "Name of the main CloudWatch billing alarm"
  value       = aws_cloudwatch_metric_alarm.billing.alarm_name
}

output "warning_alarm_arn" {
  description = "ARN of the warning CloudWatch billing alarm (empty if warning_threshold = 0)"
  value       = var.warning_threshold > 0 ? aws_cloudwatch_metric_alarm.warning[0].arn : ""
}

output "warning_alarm_name" {
  description = "Name of the warning CloudWatch billing alarm (empty if warning_threshold = 0)"
  value       = var.warning_threshold > 0 ? aws_cloudwatch_metric_alarm.warning[0].alarm_name : ""
}

output "service_alarm_arns" {
  description = "Map of AWS service names to their CloudWatch billing alarm ARNs"
  value       = { for k, v in aws_cloudwatch_metric_alarm.service : k => v.arn }
}

output "budget_id" {
  description = "ID of the AWS Budget (empty if create_budget = false)"
  value       = var.create_budget ? aws_budgets_budget.monthly[0].id : ""
}

output "budget_name" {
  description = "Name of the AWS Budget (empty if create_budget = false)"
  value       = var.create_budget ? aws_budgets_budget.monthly[0].name : ""
}

output "kms_key_id" {
  description = "ID of the KMS key used for SNS encryption (empty if enable_encryption = false)"
  value       = var.enable_encryption ? aws_kms_key.sns[0].key_id : ""
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for SNS encryption (empty if enable_encryption = false)"
  value       = var.enable_encryption ? aws_kms_key.sns[0].arn : ""
}
