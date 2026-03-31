locals {
  merged_tags = merge({ FreeTier = "true" }, var.tags)
  is_fifo     = endswith(var.queue_name, ".fifo")
  dlq_name    = local.is_fifo ? "${replace(var.queue_name, ".fifo", "")}-dlq.fifo" : "${var.queue_name}-dlq"
}

# ---------------------------------------------------------------------------
# Dead-letter queue (optional)
# Always-free: 1M requests/month (shared across all SQS queues)
# ---------------------------------------------------------------------------

resource "aws_sqs_queue" "dlq" {
  count = var.create_dead_letter_queue ? 1 : 0

  name                        = local.dlq_name
  fifo_queue                  = local.is_fifo
  content_based_deduplication = local.is_fifo
  message_retention_seconds   = var.message_retention_seconds
  sqs_managed_sse_enabled     = var.enable_encryption

  tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# SQS Queue
# Always-free: 1M requests/month
# ---------------------------------------------------------------------------

resource "aws_sqs_queue" "main" {
  name                        = var.queue_name
  fifo_queue                  = local.is_fifo
  content_based_deduplication = local.is_fifo

  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  max_message_size           = var.max_message_size
  receive_wait_time_seconds  = var.receive_wait_time_seconds
  delay_seconds              = var.delay_seconds

  sqs_managed_sse_enabled = var.enable_encryption

  redrive_policy = var.create_dead_letter_queue ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.max_receive_count
  }) : null

  tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# CloudWatch alarms (optional)
# Always-free: 10 alarms/month
# ---------------------------------------------------------------------------

# Alarm when queue depth is high (messages waiting to be processed)
resource "aws_cloudwatch_metric_alarm" "queue_depth" {
  count = var.create_cloudwatch_alarm ? 1 : 0

  alarm_name          = "${var.queue_name}-depth-high"
  alarm_description   = "SQS queue ${var.queue_name} has more than ${var.alarm_depth_threshold} messages"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Maximum"
  threshold           = var.alarm_depth_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = aws_sqs_queue.main.name
  }

  alarm_actions = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  tags = local.merged_tags
}

# Alarm when messages start appearing in the DLQ
resource "aws_cloudwatch_metric_alarm" "dlq_depth" {
  count = var.create_dead_letter_queue && var.create_cloudwatch_alarm ? 1 : 0

  alarm_name          = "${var.queue_name}-dlq-messages"
  alarm_description   = "Messages detected in dead-letter queue ${local.dlq_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Maximum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = aws_sqs_queue.dlq[0].name
  }

  alarm_actions = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  tags = local.merged_tags
}
