/**
 * AWS Billing Alerts Module
 * 
 * Creates CloudWatch billing alarms with SNS notifications to monitor AWS costs
 * and prevent unexpected charges when using free tier resources.
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

# SNS Topic for billing alerts
resource "aws_sns_topic" "billing_alerts" {
  name              = var.sns_topic_name
  display_name      = "AWS Billing Alerts"
  kms_master_key_id = var.enable_encryption ? aws_kms_key.sns[0].id : null

  tags = merge(
    var.tags,
    {
      Name        = var.sns_topic_name
      Purpose     = "BillingAlerts"
      ManagedBy   = "Terraform"
    }
  )
}

# Optional: KMS key for SNS topic encryption
resource "aws_kms_key" "sns" {
  count = var.enable_encryption ? 1 : 0

  description             = "KMS key for SNS topic encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    {
      Name      = "${var.sns_topic_name}-kms"
      ManagedBy = "Terraform"
    }
  )
}

resource "aws_kms_alias" "sns" {
  count = var.enable_encryption ? 1 : 0

  name          = "alias/${var.sns_topic_name}"
  target_key_id = aws_kms_key.sns[0].key_id
}

# Email subscription to SNS topic
resource "aws_sns_topic_subscription" "email_alerts" {
  count = var.email_address != "" ? 1 : 0

  topic_arn = aws_sns_topic.billing_alerts.arn
  protocol  = "email"
  endpoint  = var.email_address
}

# Optional: SMS subscription
resource "aws_sns_topic_subscription" "sms_alerts" {
  count = var.sms_number != "" ? 1 : 0

  topic_arn = aws_sns_topic.billing_alerts.arn
  protocol  = "sms"
  endpoint  = var.sms_number
}

# Optional: HTTPS endpoint subscription
resource "aws_sns_topic_subscription" "https_alerts" {
  count = var.https_endpoint != "" ? 1 : 0

  topic_arn = aws_sns_topic.billing_alerts.arn
  protocol  = "https"
  endpoint  = var.https_endpoint
}

# CloudWatch billing alarm - Main threshold
resource "aws_cloudwatch_metric_alarm" "billing_alert" {
  alarm_name          = var.alarm_name
  alarm_description   = "Alert when AWS charges exceed $${var.monthly_threshold}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 21600  # 6 hours
  statistic           = "Maximum"
  threshold           = var.monthly_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    Currency = var.currency
  }

  alarm_actions = [aws_sns_topic.billing_alerts.arn]
  ok_actions    = var.send_ok_notifications ? [aws_sns_topic.billing_alerts.arn] : []

  tags = merge(
    var.tags,
    {
      Name      = var.alarm_name
      ManagedBy = "Terraform"
    }
  )
}

# Additional warning alarm at lower threshold
resource "aws_cloudwatch_metric_alarm" "billing_warning" {
  count = var.warning_threshold > 0 ? 1 : 0

  alarm_name          = "${var.alarm_name}-warning"
  alarm_description   = "Warning when AWS charges exceed $${var.warning_threshold}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 21600  # 6 hours
  statistic           = "Maximum"
  threshold           = var.warning_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    Currency = var.currency
  }

  alarm_actions = [aws_sns_topic.billing_alerts.arn]

  tags = merge(
    var.tags,
    {
      Name      = "${var.alarm_name}-warning"
      Type      = "Warning"
      ManagedBy = "Terraform"
    }
  )
}

# Per-service billing alarms (optional)
resource "aws_cloudwatch_metric_alarm" "service_billing_alert" {
  for_each = var.service_thresholds

  alarm_name          = "${var.alarm_name}-${each.key}"
  alarm_description   = "Alert when ${each.key} charges exceed $${each.value}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 21600  # 6 hours
  statistic           = "Maximum"
  threshold           = each.value
  treat_missing_data  = "notBreaching"

  dimensions = {
    Currency    = var.currency
    ServiceName = each.key
  }

  alarm_actions = [aws_sns_topic.billing_alerts.arn]

  tags = merge(
    var.tags,
    {
      Name        = "${var.alarm_name}-${each.key}"
      ServiceName = each.key
      ManagedBy   = "Terraform"
    }
  )
}

# AWS Budget (requires AWS Budgets API)
resource "aws_budgets_budget" "monthly_cost" {
  count = var.create_budget ? 1 : 0

  name              = var.budget_name
  budget_type       = "COST"
  limit_amount      = var.monthly_threshold
  limit_unit        = var.currency
  time_unit         = "MONTHLY"
  time_period_start = formatdate("YYYY-MM-01_00:00", timestamp())

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_email_addresses = var.email_address != "" ? [var.email_address] : []
    subscriber_sns_topic_arns  = [aws_sns_topic.billing_alerts.arn]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_email_addresses = var.email_address != "" ? [var.email_address] : []
    subscriber_sns_topic_arns  = [aws_sns_topic.billing_alerts.arn]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 90
    threshold_type            = "PERCENTAGE"
    notification_type         = "FORECASTED"
    subscriber_email_addresses = var.email_address != "" ? [var.email_address] : []
    subscriber_sns_topic_arns  = [aws_sns_topic.billing_alerts.arn]
  }

  tags = merge(
    var.tags,
    {
      Name      = var.budget_name
      ManagedBy = "Terraform"
    }
  )
}
