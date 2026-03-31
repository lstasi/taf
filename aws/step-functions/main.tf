locals {
  merged_tags    = merge({ FreeTier = "true" }, var.tags)
  effective_role = var.iam_role_arn != "" ? var.iam_role_arn : aws_iam_role.sfn[0].arn
}

# ---------------------------------------------------------------------------
# IAM role (created when iam_role_arn is not provided)
# ---------------------------------------------------------------------------

resource "aws_iam_role" "sfn" {
  count = var.iam_role_arn == "" ? 1 : 0

  name = "${var.name}-sfn-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "states.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.merged_tags
}

# Allow the state machine to write CloudWatch Logs
resource "aws_iam_role_policy" "sfn_logs" {
  count = var.iam_role_arn == "" && var.enable_logging ? 1 : 0

  name = "${var.name}-sfn-logs"
  role = aws_iam_role.sfn[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogDelivery",
        "logs:GetLogDelivery",
        "logs:UpdateLogDelivery",
        "logs:DeleteLogDelivery",
        "logs:ListLogDeliveries",
        "logs:PutLogEvents",
        "logs:PutResourcePolicy",
        "logs:DescribeResourcePolicies",
        "logs:DescribeLogGroups",
      ]
      Resource = "*"
    }]
  })
}

# Allow the state machine to invoke Lambda functions
resource "aws_iam_role_policy" "sfn_lambda" {
  count = var.iam_role_arn == "" && length(var.lambda_arns) > 0 ? 1 : 0

  name = "${var.name}-sfn-lambda"
  role = aws_iam_role.sfn[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["lambda:InvokeFunction"]
      Resource = var.lambda_arns
    }]
  })
}

# Allow the state machine to read/write DynamoDB tables
resource "aws_iam_role_policy" "sfn_dynamodb" {
  count = var.iam_role_arn == "" && length(var.dynamodb_table_arns) > 0 ? 1 : 0

  name = "${var.name}-sfn-dynamodb"
  role = aws_iam_role.sfn[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan",
      ]
      Resource = var.dynamodb_table_arns
    }]
  })
}

# Allow the state machine to publish to SNS topics
resource "aws_iam_role_policy" "sfn_sns" {
  count = var.iam_role_arn == "" && length(var.sns_topic_arns) > 0 ? 1 : 0

  name = "${var.name}-sfn-sns"
  role = aws_iam_role.sfn[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["sns:Publish"]
      Resource = var.sns_topic_arns
    }]
  })
}

# Allow the state machine to send messages to SQS queues
resource "aws_iam_role_policy" "sfn_sqs" {
  count = var.iam_role_arn == "" && length(var.sqs_queue_arns) > 0 ? 1 : 0

  name = "${var.name}-sfn-sqs"
  role = aws_iam_role.sfn[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["sqs:SendMessage"]
      Resource = var.sqs_queue_arns
    }]
  })
}

# Additional managed policies attached to the auto-created role
resource "aws_iam_role_policy_attachment" "additional" {
  count = var.iam_role_arn == "" ? length(var.additional_policy_arns) : 0

  role       = aws_iam_role.sfn[0].name
  policy_arn = var.additional_policy_arns[count.index]
}

# ---------------------------------------------------------------------------
# CloudWatch Log Group (created when enable_logging = true)
# Always-free: 5 GB log ingestion/month
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "sfn" {
  count = var.enable_logging ? 1 : 0

  name              = "/aws/states/${var.name}"
  retention_in_days = var.log_retention_days > 0 ? var.log_retention_days : null

  tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# Step Functions State Machine (Standard workflow)
# Always-free: 4,000 state transitions/month
# ---------------------------------------------------------------------------

resource "aws_sfn_state_machine" "main" {
  name     = var.name
  role_arn = local.effective_role
  type     = "STANDARD"

  definition = var.definition

  dynamic "logging_configuration" {
    for_each = var.enable_logging ? [1] : []
    content {
      log_destination        = "${aws_cloudwatch_log_group.sfn[0].arn}:*"
      include_execution_data = false
      level                  = var.log_level
    }
  }

  tags = local.merged_tags

  depends_on = [
    aws_iam_role_policy.sfn_logs,
  ]
}

# ---------------------------------------------------------------------------
# CloudWatch alarm for execution failures (optional)
# Always-free: 10 alarms/month
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "execution_failures" {
  count = var.create_cloudwatch_alarm ? 1 : 0

  alarm_name          = "${var.name}-execution-failures"
  alarm_description   = "Step Functions state machine ${var.name} had ${var.alarm_failure_threshold} or more failed executions"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ExecutionsFailed"
  namespace           = "AWS/States"
  period              = 300
  statistic           = "Sum"
  threshold           = var.alarm_failure_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    StateMachineArn = aws_sfn_state_machine.main.arn
  }

  alarm_actions = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  tags = local.merged_tags
}
