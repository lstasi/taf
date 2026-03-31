locals {
  merged_tags = merge({ FreeTier = "true" }, var.tags)

  # Collect all attribute definitions needed (hash/range keys + GSI keys)
  gsi_hash_attrs = [
    for gsi in var.global_secondary_indexes : {
      name = gsi.hash_key
      type = gsi.hash_key_type
    }
  ]
  gsi_range_attrs = [
    for gsi in var.global_secondary_indexes : {
      name = gsi.range_key
      type = gsi.range_key_type
    } if gsi.range_key != ""
  ]

  # Deduplicate all attribute definitions by name
  all_attrs = distinct(concat(
    [{ name = var.hash_key, type = var.hash_key_type }],
    var.range_key != "" ? [{ name = var.range_key, type = var.range_key_type }] : [],
    local.gsi_hash_attrs,
    local.gsi_range_attrs,
  ))
}

# ---------------------------------------------------------------------------
# DynamoDB table
# Always-free: 25 GB storage, 25 RCU, 25 WCU (provisioned capacity mode)
# ---------------------------------------------------------------------------

resource "aws_dynamodb_table" "main" {
  name           = var.table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = var.hash_key
  range_key      = var.range_key != "" ? var.range_key : null

  dynamic "attribute" {
    for_each = local.all_attrs
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  # Time-to-Live
  dynamic "ttl" {
    for_each = var.ttl_attribute != "" ? [1] : []
    content {
      attribute_name = var.ttl_attribute
      enabled        = true
    }
  }

  # Server-side encryption (uses the AWS-managed DynamoDB key — free)
  server_side_encryption {
    enabled = var.server_side_encryption
  }

  # Global Secondary Indexes
  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = global_secondary_index.value.range_key != "" ? global_secondary_index.value.range_key : null
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = global_secondary_index.value.projection_type == "INCLUDE" ? global_secondary_index.value.non_key_attributes : null
      read_capacity      = global_secondary_index.value.read_capacity
      write_capacity     = global_secondary_index.value.write_capacity
    }
  }

  tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# CloudWatch alarms for capacity consumption (optional)
# Warn when consumed capacity approaches provisioned limits.
# Always-free: 10 alarms/month
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "read_capacity" {
  count = var.create_cloudwatch_alarm ? 1 : 0

  alarm_name          = "${var.table_name}-read-capacity-high"
  alarm_description   = "DynamoDB table ${var.table_name} consumed read capacity exceeded 80% of provisioned"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  metric_name         = "ConsumedReadCapacityUnits"
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Sum"
  threshold           = var.read_capacity * 300 * 0.8 # 80% of provisioned capacity per 5-min period
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = aws_dynamodb_table.main.name
  }

  alarm_actions = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  tags = local.merged_tags
}

resource "aws_cloudwatch_metric_alarm" "write_capacity" {
  count = var.create_cloudwatch_alarm ? 1 : 0

  alarm_name          = "${var.table_name}-write-capacity-high"
  alarm_description   = "DynamoDB table ${var.table_name} consumed write capacity exceeded 80% of provisioned"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  metric_name         = "ConsumedWriteCapacityUnits"
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Sum"
  threshold           = var.write_capacity * 300 * 0.8 # 80% of provisioned capacity per 5-min period
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = aws_dynamodb_table.main.name
  }

  alarm_actions = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  tags = local.merged_tags
}
