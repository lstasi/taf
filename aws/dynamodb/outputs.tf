output "table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.main.arn
}

output "table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.main.name
}

output "table_id" {
  description = "ID of the DynamoDB table (same as the table name)"
  value       = aws_dynamodb_table.main.id
}

output "table_stream_arn" {
  description = "ARN of the DynamoDB table stream (empty if streams are not enabled)"
  value       = aws_dynamodb_table.main.stream_arn
}

output "read_capacity_alarm_arn" {
  description = "ARN of the read capacity CloudWatch alarm (empty if create_cloudwatch_alarm = false)"
  value       = var.create_cloudwatch_alarm ? aws_cloudwatch_metric_alarm.read_capacity[0].arn : ""
}

output "write_capacity_alarm_arn" {
  description = "ARN of the write capacity CloudWatch alarm (empty if create_cloudwatch_alarm = false)"
  value       = var.create_cloudwatch_alarm ? aws_cloudwatch_metric_alarm.write_capacity[0].arn : ""
}
