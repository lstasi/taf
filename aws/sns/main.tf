locals {
  merged_tags = merge({ FreeTier = "true" }, var.tags)
  is_fifo     = endswith(var.topic_name, ".fifo")
}

# ---------------------------------------------------------------------------
# KMS key (optional, used to encrypt the SNS topic)
# ---------------------------------------------------------------------------

resource "aws_kms_key" "sns" {
  count = var.enable_encryption ? 1 : 0

  description             = "KMS key for SNS topic ${var.topic_name} encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = local.merged_tags
}

resource "aws_kms_alias" "sns" {
  count = var.enable_encryption ? 1 : 0

  name          = "alias/${replace(var.topic_name, ".fifo", "")}-key"
  target_key_id = aws_kms_key.sns[0].key_id
}

# ---------------------------------------------------------------------------
# SNS Topic
# Always-free: 1,000 email deliveries/month, 1M mobile push notifications,
# 100,000 HTTP/S deliveries/month
# ---------------------------------------------------------------------------

resource "aws_sns_topic" "main" {
  name         = var.topic_name
  display_name = var.display_name != "" ? var.display_name : null

  fifo_topic                  = local.is_fifo
  content_based_deduplication = local.is_fifo

  kms_master_key_id = var.enable_encryption ? aws_kms_key.sns[0].arn : null

  http_success_feedback_sample_rate = null

  tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# Subscriptions
# ---------------------------------------------------------------------------

resource "aws_sns_topic_subscription" "email" {
  count = length(var.email_subscriptions)

  topic_arn = aws_sns_topic.main.arn
  protocol  = "email"
  endpoint  = var.email_subscriptions[count.index]
}

resource "aws_sns_topic_subscription" "https" {
  count = length(var.https_subscriptions)

  topic_arn       = aws_sns_topic.main.arn
  protocol        = "https"
  endpoint        = var.https_subscriptions[count.index]
  delivery_policy = var.delivery_policy != "" ? var.delivery_policy : null
}

resource "aws_sns_topic_subscription" "sqs" {
  count = length(var.sqs_subscriptions)

  topic_arn = aws_sns_topic.main.arn
  protocol  = "sqs"
  endpoint  = var.sqs_subscriptions[count.index]
}

resource "aws_sns_topic_subscription" "lambda" {
  count = length(var.lambda_subscriptions)

  topic_arn = aws_sns_topic.main.arn
  protocol  = "lambda"
  endpoint  = var.lambda_subscriptions[count.index]
}

# ---------------------------------------------------------------------------
# CloudWatch alarm for notification failures (optional)
# Always-free: 10 alarms/month
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "failures" {
  count = var.create_cloudwatch_alarm ? 1 : 0

  alarm_name          = "${var.topic_name}-notification-failures"
  alarm_description   = "SNS topic ${var.topic_name} notification failure count exceeded ${var.alarm_failure_threshold}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "NumberOfNotificationsFailed"
  namespace           = "AWS/SNS"
  period              = 300
  statistic           = "Sum"
  threshold           = var.alarm_failure_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    TopicName = aws_sns_topic.main.name
  }

  alarm_actions = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  tags = local.merged_tags
}
