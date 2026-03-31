locals {
  merged_tags = merge({ FreeTier = "true" }, var.tags)
}

# ---------------------------------------------------------------------------
# CloudWatch Log Groups
# Always-free: 5 GB log data ingestion/month, 5 GB log data archival
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "groups" {
  for_each = var.log_groups

  name              = each.key
  retention_in_days = each.value.retention_in_days > 0 ? each.value.retention_in_days : null

  tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# CloudWatch Metric Alarms
# Always-free: 10 alarms/month
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "alarms" {
  for_each = var.alarms

  alarm_name          = "${var.name_prefix}-${each.key}"
  alarm_description   = each.value.alarm_description
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  treat_missing_data  = each.value.treat_missing_data

  dimensions    = length(each.value.dimensions) > 0 ? each.value.dimensions : null
  alarm_actions = each.value.sns_topic_arn != "" ? [each.value.sns_topic_arn] : []

  tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# CloudWatch Dashboard (optional)
# Always-free: 3 dashboards, 50 metrics per dashboard
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_dashboard" "main" {
  count = var.dashboard_name != "" ? 1 : 0

  dashboard_name = var.dashboard_name
  dashboard_body = var.dashboard_body
}
