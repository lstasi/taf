output "topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.main.arn
}

output "topic_name" {
  description = "Name of the SNS topic"
  value       = aws_sns_topic.main.name
}

output "topic_id" {
  description = "ID of the SNS topic (same as the ARN)"
  value       = aws_sns_topic.main.id
}

output "kms_key_id" {
  description = "ID of the KMS key used for SNS encryption (empty if enable_encryption = false)"
  value       = var.enable_encryption ? aws_kms_key.sns[0].key_id : ""
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for SNS encryption (empty if enable_encryption = false)"
  value       = var.enable_encryption ? aws_kms_key.sns[0].arn : ""
}

output "failure_alarm_arn" {
  description = "ARN of the notification failure CloudWatch alarm (empty if create_cloudwatch_alarm = false)"
  value       = var.create_cloudwatch_alarm ? aws_cloudwatch_metric_alarm.failures[0].arn : ""
}
