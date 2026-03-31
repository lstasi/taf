output "state_machine_arn" {
  description = "ARN of the Step Functions state machine"
  value       = aws_sfn_state_machine.main.arn
}

output "state_machine_name" {
  description = "Name of the Step Functions state machine"
  value       = aws_sfn_state_machine.main.name
}

output "state_machine_id" {
  description = "ID of the Step Functions state machine (same as the ARN)"
  value       = aws_sfn_state_machine.main.id
}

output "iam_role_arn" {
  description = "ARN of the IAM role attached to the state machine"
  value       = local.effective_role
}

output "iam_role_name" {
  description = "Name of the auto-created IAM role (empty if an existing role was provided)"
  value       = var.iam_role_arn == "" ? aws_iam_role.sfn[0].name : ""
}

output "log_group_name" {
  description = "Name of the CloudWatch log group for execution logs (empty if enable_logging = false)"
  value       = var.enable_logging ? aws_cloudwatch_log_group.sfn[0].name : ""
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group for execution logs (empty if enable_logging = false)"
  value       = var.enable_logging ? aws_cloudwatch_log_group.sfn[0].arn : ""
}

output "failure_alarm_arn" {
  description = "ARN of the execution failure CloudWatch alarm (empty if create_cloudwatch_alarm = false)"
  value       = var.create_cloudwatch_alarm ? aws_cloudwatch_metric_alarm.execution_failures[0].arn : ""
}
