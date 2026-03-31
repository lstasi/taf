locals {
  merged_tags = merge({ FreeTier = "true" }, var.tags)

  ok_actions = var.send_ok_notifications ? [aws_sns_topic.billing.arn] : []
}

# ---------------------------------------------------------------------------
# KMS key (optional, used to encrypt the SNS topic)
# Always-free: 20,000 requests/month
# ---------------------------------------------------------------------------

resource "aws_kms_key" "sns" {
  count = var.enable_encryption ? 1 : 0

  description             = "KMS key for billing-alerts SNS topic encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = local.merged_tags
}

resource "aws_kms_alias" "sns" {
  count = var.enable_encryption ? 1 : 0

  name          = "alias/${var.sns_topic_name}-key"
  target_key_id = aws_kms_key.sns[0].key_id
}

# ---------------------------------------------------------------------------
# SNS topic for billing alert notifications
# Always-free: 1,000 email deliveries/month, 1M mobile push notifications
# ---------------------------------------------------------------------------

resource "aws_sns_topic" "billing" {
  name              = var.sns_topic_name
  kms_master_key_id = var.enable_encryption ? aws_kms_key.sns[0].arn : null

  tags = local.merged_tags
}

# Email subscription (created only when email_address is provided)
resource "aws_sns_topic_subscription" "email" {
  count = var.email_address != "" ? 1 : 0

  topic_arn = aws_sns_topic.billing.arn
  protocol  = "email"
  endpoint  = var.email_address
}

# SMS subscription (created only when sms_number is provided)
resource "aws_sns_topic_subscription" "sms" {
  count = var.sms_number != "" ? 1 : 0

  topic_arn = aws_sns_topic.billing.arn
  protocol  = "sms"
  endpoint  = var.sms_number
}

# HTTPS/webhook subscription (created only when https_endpoint is provided)
resource "aws_sns_topic_subscription" "https" {
  count = var.https_endpoint != "" ? 1 : 0

  topic_arn = aws_sns_topic.billing.arn
  protocol  = "https"
  endpoint  = var.https_endpoint
}

# ---------------------------------------------------------------------------
# CloudWatch billing alarm — main threshold
# NOTE: CloudWatch billing metrics are only available in us-east-1.
# Always-free: 10 alarms/month
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "billing" {
  alarm_name          = var.alarm_name
  alarm_description   = "Estimated AWS charges exceeded ${var.monthly_threshold} ${var.currency}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 21600 # 6 hours
  statistic           = "Maximum"
  threshold           = var.monthly_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    Currency = var.currency
  }

  alarm_actions = [aws_sns_topic.billing.arn]
  ok_actions    = local.ok_actions

  tags = local.merged_tags
}

# CloudWatch billing alarm — warning threshold (created when warning_threshold > 0)
resource "aws_cloudwatch_metric_alarm" "warning" {
  count = var.warning_threshold > 0 ? 1 : 0

  alarm_name          = "${var.alarm_name}-warning"
  alarm_description   = "Early warning: estimated AWS charges exceeded ${var.warning_threshold} ${var.currency}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 21600 # 6 hours
  statistic           = "Maximum"
  threshold           = var.warning_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    Currency = var.currency
  }

  alarm_actions = [aws_sns_topic.billing.arn]
  ok_actions    = local.ok_actions

  tags = local.merged_tags
}

# Per-service billing alarms (created for each entry in service_thresholds)
resource "aws_cloudwatch_metric_alarm" "service" {
  for_each = var.service_thresholds

  alarm_name          = "${var.alarm_name}-${replace(lower(each.key), " ", "-")}"
  alarm_description   = "Estimated charges for ${each.key} exceeded ${each.value} ${var.currency}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 21600 # 6 hours
  statistic           = "Maximum"
  threshold           = each.value
  treat_missing_data  = "notBreaching"

  dimensions = {
    Currency    = var.currency
    ServiceName = each.key
  }

  alarm_actions = [aws_sns_topic.billing.arn]
  ok_actions    = local.ok_actions

  tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# AWS Budget (optional)
# Always-free: first 2 budgets are free
# ---------------------------------------------------------------------------

resource "aws_budgets_budget" "monthly" {
  count = var.create_budget ? 1 : 0

  name         = var.budget_name
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_threshold)
  limit_unit   = var.currency
  time_unit    = "MONTHLY"

  # Notify at 80% actual spend
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_sns_topic_arns  = [aws_sns_topic.billing.arn]
    subscriber_email_addresses = var.email_address != "" ? [var.email_address] : []
  }

  # Notify at 90% forecasted spend
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 90
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_sns_topic_arns  = [aws_sns_topic.billing.arn]
    subscriber_email_addresses = var.email_address != "" ? [var.email_address] : []
  }

  # Notify when 100% of budget is used
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_sns_topic_arns  = [aws_sns_topic.billing.arn]
    subscriber_email_addresses = var.email_address != "" ? [var.email_address] : []
  }
}
