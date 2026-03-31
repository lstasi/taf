output "queue_arn" {
  description = "ARN of the SQS queue"
  value       = aws_sqs_queue.main.arn
}

output "queue_url" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.main.url
}

output "queue_name" {
  description = "Name of the SQS queue"
  value       = aws_sqs_queue.main.name
}

output "queue_id" {
  description = "ID of the SQS queue (same as the URL)"
  value       = aws_sqs_queue.main.id
}

output "dlq_arn" {
  description = "ARN of the dead-letter queue (empty if create_dead_letter_queue = false)"
  value       = var.create_dead_letter_queue ? aws_sqs_queue.dlq[0].arn : ""
}

output "dlq_url" {
  description = "URL of the dead-letter queue (empty if create_dead_letter_queue = false)"
  value       = var.create_dead_letter_queue ? aws_sqs_queue.dlq[0].url : ""
}

output "dlq_name" {
  description = "Name of the dead-letter queue (empty if create_dead_letter_queue = false)"
  value       = var.create_dead_letter_queue ? aws_sqs_queue.dlq[0].name : ""
}

output "queue_depth_alarm_arn" {
  description = "ARN of the queue depth CloudWatch alarm (empty if create_cloudwatch_alarm = false)"
  value       = var.create_cloudwatch_alarm ? aws_cloudwatch_metric_alarm.queue_depth[0].arn : ""
}

output "dlq_depth_alarm_arn" {
  description = "ARN of the DLQ depth CloudWatch alarm (empty if DLQ or alarms are disabled)"
  value       = var.create_dead_letter_queue && var.create_cloudwatch_alarm ? aws_cloudwatch_metric_alarm.dlq_depth[0].arn : ""
}
