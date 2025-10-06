/**
 * AWS Lambda Free Tier Module
 * 
 * Creates Lambda functions within AWS free tier limits:
 * - 1 million requests per month (always free)
 * - 400,000 GB-seconds of compute time (always free)
 */

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# IAM role for Lambda function
resource "aws_iam_role" "lambda" {
  name_prefix = "${var.function_name}-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name      = "${var.function_name}-role"
      ManagedBy = "Terraform"
    }
  )
}

# Attach basic execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach VPC execution policy if VPC config is provided
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  count = var.vpc_config != null ? 1 : 0

  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Attach additional policies
resource "aws_iam_role_policy_attachment" "additional" {
  for_each = toset(var.additional_policy_arns)

  role       = aws_iam_role.lambda.name
  policy_arn = each.value
}

# CloudWatch log group
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.log_kms_key_id

  tags = merge(
    var.tags,
    {
      Name      = "${var.function_name}-logs"
      ManagedBy = "Terraform"
    }
  )
}

# Lambda function
resource "aws_lambda_function" "free_tier" {
  filename         = var.filename
  source_code_hash = var.filename != "" ? filebase64sha256(var.filename) : null
  s3_bucket        = var.s3_bucket
  s3_key           = var.s3_key
  s3_object_version = var.s3_object_version

  function_name = var.function_name
  role          = aws_iam_role.lambda.arn
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size

  reserved_concurrent_executions = var.reserved_concurrent_executions

  environment {
    variables = var.environment_variables
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn != "" ? [1] : []
    content {
      target_arn = var.dead_letter_target_arn
    }
  }

  tracing_config {
    mode = var.enable_xray_tracing ? "Active" : "PassThrough"
  }

  tags = merge(
    var.tags,
    {
      Name      = var.function_name
      FreeTier  = "true"
      ManagedBy = "Terraform"
    }
  )

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy_attachment.lambda_basic
  ]
}

# Lambda function URL (if enabled)
resource "aws_lambda_function_url" "free_tier" {
  count = var.enable_function_url ? 1 : 0

  function_name      = aws_lambda_function.free_tier.function_name
  authorization_type = var.function_url_auth_type

  dynamic "cors" {
    for_each = var.function_url_cors != null ? [var.function_url_cors] : []
    content {
      allow_credentials = cors.value.allow_credentials
      allow_headers     = cors.value.allow_headers
      allow_methods     = cors.value.allow_methods
      allow_origins     = cors.value.allow_origins
      expose_headers    = cors.value.expose_headers
      max_age           = cors.value.max_age
    }
  }
}

# CloudWatch alarm for invocation errors
resource "aws_cloudwatch_metric_alarm" "errors" {
  count = var.enable_error_alarm ? 1 : 0

  alarm_name          = "${var.function_name}-errors"
  alarm_description   = "Alert when Lambda function has errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = var.error_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.free_tier.function_name
  }

  alarm_actions = var.alarm_actions

  tags = merge(
    var.tags,
    {
      Name      = "${var.function_name}-errors"
      ManagedBy = "Terraform"
    }
  )
}

# CloudWatch alarm for throttles
resource "aws_cloudwatch_metric_alarm" "throttles" {
  count = var.enable_throttle_alarm ? 1 : 0

  alarm_name          = "${var.function_name}-throttles"
  alarm_description   = "Alert when Lambda function is throttled"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.free_tier.function_name
  }

  alarm_actions = var.alarm_actions

  tags = merge(
    var.tags,
    {
      Name      = "${var.function_name}-throttles"
      ManagedBy = "Terraform"
    }
  )
}

# CloudWatch alarm for invocation count (to monitor free tier usage)
resource "aws_cloudwatch_metric_alarm" "invocations" {
  count = var.enable_invocation_alarm ? 1 : 0

  alarm_name          = "${var.function_name}-high-invocations"
  alarm_description   = "Alert when Lambda invocations approach free tier limits"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Invocations"
  namespace           = "AWS/Lambda"
  period              = 86400  # 1 day
  statistic           = "Sum"
  threshold           = var.daily_invocation_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.free_tier.function_name
  }

  alarm_actions = var.alarm_actions

  tags = merge(
    var.tags,
    {
      Name      = "${var.function_name}-invocations"
      ManagedBy = "Terraform"
    }
  )
}
