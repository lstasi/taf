locals {
  merged_tags = merge({ FreeTier = "true" }, var.freeform_tags)
}

# OCI Notifications topic for billing alerts
resource "oci_ons_notification_topic" "billing_topic" {
  compartment_id = var.compartment_id
  name           = "${var.budget_name}-topic"
  description    = "Notification topic for billing alerts"

  freeform_tags = local.merged_tags
}

# Email subscription (created only when email_address is provided)
resource "oci_ons_subscription" "email_subscription" {
  count = var.email_address != "" ? 1 : 0

  compartment_id = var.compartment_id
  topic_id       = oci_ons_notification_topic.billing_topic.id
  endpoint       = var.email_address
  protocol       = "EMAIL"

  freeform_tags = local.merged_tags
}

# HTTPS/webhook subscription (created only when https_endpoint is provided)
resource "oci_ons_subscription" "https_subscription" {
  count = var.https_endpoint != "" ? 1 : 0

  compartment_id = var.compartment_id
  topic_id       = oci_ons_notification_topic.billing_topic.id
  endpoint       = var.https_endpoint
  protocol       = "HTTPS"

  freeform_tags = local.merged_tags
}

# OCI Budget for the tenancy
resource "oci_budget_budget" "monthly_budget" {
  compartment_id = var.tenancy_id
  amount         = var.monthly_threshold
  reset_period   = "MONTHLY"
  target_type    = "COMPARTMENT"
  targets        = [var.tenancy_id]

  display_name  = var.budget_name
  description   = "Always-free tier spending budget — threshold: ${var.monthly_threshold} ${var.currency}"

  freeform_tags = local.merged_tags
}

# Alert rule: actual spending at 80%
resource "oci_budget_alert_rule" "actual_alert" {
  budget_id      = oci_budget_budget.monthly_budget.id
  type           = "ACTUAL"
  threshold      = 80
  threshold_type = "PERCENTAGE"
  recipients     = var.email_address != "" ? var.email_address : null
  message        = "Actual spending has reached 80% of the monthly budget (${var.monthly_threshold} ${var.currency})."
  display_name   = "${var.budget_name}-actual-80pct"
}

# Alert rule: forecast spending at 90%
resource "oci_budget_alert_rule" "forecast_alert" {
  budget_id      = oci_budget_budget.monthly_budget.id
  type           = "FORECAST"
  threshold      = 90
  threshold_type = "PERCENTAGE"
  recipients     = var.email_address != "" ? var.email_address : null
  message        = "Forecast spending is projected to reach 90% of the monthly budget (${var.monthly_threshold} ${var.currency})."
  display_name   = "${var.budget_name}-forecast-90pct"
}

# Warning alert rule (created only when warning_threshold > 0)
resource "oci_budget_alert_rule" "warning_alert" {
  count = var.warning_threshold > 0 ? 1 : 0

  budget_id      = oci_budget_budget.monthly_budget.id
  type           = "ACTUAL"
  threshold      = (var.warning_threshold / var.monthly_threshold) * 100
  threshold_type = "PERCENTAGE"
  recipients     = var.email_address != "" ? var.email_address : null
  message        = "Early warning: spending has reached ${var.warning_threshold} ${var.currency}."
  display_name   = "${var.budget_name}-warning"
}
