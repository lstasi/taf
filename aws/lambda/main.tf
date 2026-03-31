locals {
  merged_tags    = merge({ FreeTier = "true" }, var.tags)
  effective_role = var.iam_role_arn != "" ? var.iam_role_arn : aws_iam_role.lambda[0].arn
}

# ---------------------------------------------------------------------------
# IAM role (created when iam_role_arn is not provided)
# ---------------------------------------------------------------------------

resource "aws_iam_role" "lambda" {
  count = var.iam_role_arn == "" ? 1 : 0

  name = "${var.function_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.merged_tags
}

# Basic execution policy — allows writing CloudWatch Logs
resource "aws_iam_role_policy_attachment" "basic_execution" {
  count = var.iam_role_arn == "" ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Additional policies (e.g. AmazonDynamoDBFullAccess) attached to the auto-created role
resource "aws_iam_role_policy_attachment" "additional" {
  count = var.iam_role_arn == "" ? length(var.additional_policy_arns) : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = var.additional_policy_arns[count.index]
}

# ---------------------------------------------------------------------------
# CloudWatch Log Group
# Always-free: 5 GB log ingestion/month, 5 GB log storage
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days > 0 ? var.log_retention_days : null

  tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# Lambda function
# Always-free: 1M requests/month, 400,000 GB-seconds compute
# ---------------------------------------------------------------------------

resource "aws_lambda_function" "main" {
  function_name = var.function_name
  description   = var.description
  role          = local.effective_role
  runtime       = var.runtime
  handler       = var.handler

  # Deployment package — either a local ZIP file or an S3 object
  filename         = var.filename
  s3_bucket        = var.s3_bucket
  s3_key           = var.s3_key
  source_code_hash = var.source_code_hash

  memory_size                    = var.memory_size
  timeout                        = var.timeout
  reserved_concurrent_executions = var.reserved_concurrent_executions

  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  # Ensure the log group is created before the function so that the first
  # invocation doesn't trigger auto-creation of a log group outside Terraform.
  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy_attachment.basic_execution,
  ]

  tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# CloudWatch alarm for Lambda error rate (optional)
# Always-free: 10 alarms/month
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "errors" {
  count = var.create_cloudwatch_alarm ? 1 : 0

  alarm_name          = "${var.function_name}-errors"
  alarm_description   = "Lambda function ${var.function_name} error count exceeded ${var.alarm_error_threshold}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = var.alarm_error_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.main.function_name
  }

  alarm_actions = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# EventBridge scheduled rule (optional)
# Always-free: 1M events/month
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "schedule" {
  count = var.schedule_expression != "" ? 1 : 0

  name                = "${var.function_name}-schedule"
  description         = "Scheduled trigger for Lambda function ${var.function_name}"
  schedule_expression = var.schedule_expression

  tags = local.merged_tags
}

resource "aws_cloudwatch_event_target" "lambda" {
  count = var.schedule_expression != "" ? 1 : 0

  rule      = aws_cloudwatch_event_rule.schedule[0].name
  target_id = "lambda"
  arn       = aws_lambda_function.main.arn
}

resource "aws_lambda_permission" "eventbridge" {
  count = var.schedule_expression != "" ? 1 : 0

  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule[0].arn
}
