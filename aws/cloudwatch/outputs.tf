output "log_group_names" {
  description = "Map of log group configuration keys to their CloudWatch log group names"
  value       = { for k, v in aws_cloudwatch_log_group.groups : k => v.name }
}

output "log_group_arns" {
  description = "Map of log group configuration keys to their CloudWatch log group ARNs"
  value       = { for k, v in aws_cloudwatch_log_group.groups : k => v.arn }
}

output "alarm_arns" {
  description = "Map of alarm configuration keys to their CloudWatch alarm ARNs"
  value       = { for k, v in aws_cloudwatch_metric_alarm.alarms : k => v.arn }
}

output "alarm_names" {
  description = "Map of alarm configuration keys to their CloudWatch alarm names"
  value       = { for k, v in aws_cloudwatch_metric_alarm.alarms : k => v.alarm_name }
}

output "dashboard_arn" {
  description = "ARN of the CloudWatch dashboard (empty if dashboard_name is not set)"
  value       = var.dashboard_name != "" ? aws_cloudwatch_dashboard.main[0].dashboard_arn : ""
}
