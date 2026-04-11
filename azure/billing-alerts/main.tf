locals {
  merged_tags = merge({ FreeTier = "true" }, var.tags)

  # Convert the absolute warning_threshold to a budget percentage for notification
  warning_threshold_pct = var.warning_threshold > 0 ? (var.warning_threshold / var.monthly_budget) * 100 : 0
}

# ---------------------------------------------------------------------------
# Current subscription data source
# ---------------------------------------------------------------------------

data "azurerm_subscription" "current" {}

# ---------------------------------------------------------------------------
# Resource group for billing alert resources
# Always-free: resource groups have no cost
# ---------------------------------------------------------------------------

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# Action group for billing alert notifications
# Always-free: up to 1,000 emails/month, 10 webhook calls/minute
# ---------------------------------------------------------------------------

resource "azurerm_monitor_action_group" "billing" {
  name                = "${var.budget_name}-action-group"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "billing"

  dynamic "email_receiver" {
    for_each = var.email_addresses
    content {
      name          = "email-${email_receiver.key}"
      email_address = email_receiver.value
    }
  }

  dynamic "webhook_receiver" {
    for_each = var.webhook_url != "" ? [var.webhook_url] : []
    content {
      name        = "webhook"
      service_uri = webhook_receiver.value
    }
  }

  tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# Subscription-level consumption budget with alert notifications
# Always-free: budgets and alerts are free in Azure Cost Management
# ---------------------------------------------------------------------------

resource "azurerm_consumption_budget_subscription" "monthly" {
  name            = var.budget_name
  subscription_id = data.azurerm_subscription.current.id
  amount          = var.monthly_budget
  time_grain      = "Monthly"

  time_period {
    start_date = var.budget_start_date
    end_date   = var.budget_end_date
  }

  dynamic "notification" {
    for_each = var.alert_thresholds
    content {
      operator       = "GreaterThanOrEqualTo"
      threshold      = notification.value.threshold
      threshold_type = notification.value.type
      enabled        = true

      contact_groups = [azurerm_monitor_action_group.billing.id]
      contact_emails = var.email_addresses
    }
  }

  # Warning notification based on warning_threshold (created when warning_threshold > 0)
  dynamic "notification" {
    for_each = var.warning_threshold > 0 ? [local.warning_threshold_pct] : []
    content {
      operator       = "GreaterThanOrEqualTo"
      threshold      = notification.value
      threshold_type = "Actual"
      enabled        = true

      contact_groups = [azurerm_monitor_action_group.billing.id]
      contact_emails = var.email_addresses
    }
  }
}

# ---------------------------------------------------------------------------
# Cost anomaly alert (optional)
# Always-free: anomaly detection is included in Azure Cost Management
# ---------------------------------------------------------------------------

resource "azurerm_cost_anomaly_alert" "main" {
  count = var.enable_anomaly_alerts ? 1 : 0

  name            = "${var.budget_name}-anomaly-alert"
  display_name    = "${var.budget_name} Cost Anomaly Alert"
  email_subject   = "Azure Cost Anomaly Detected"
  email_addresses = var.email_addresses
}
