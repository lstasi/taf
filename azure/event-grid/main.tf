# ---------------------------------------------------------------------------
# Local values
# ---------------------------------------------------------------------------

locals {
  merged_tags   = merge({ FreeTier = "true" }, var.tags)
  subscriptions = { for s in var.subscriptions : s.name => s }
}

# ---------------------------------------------------------------------------
# Resource group
# Always-free: resource groups have no cost
# ---------------------------------------------------------------------------

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.merged_tags
}

# ---------------------------------------------------------------------------
# Event Grid custom topic
# Always-free: 100,000 operations/month (publish + delivery + management)
# ---------------------------------------------------------------------------

resource "azurerm_eventgrid_topic" "main" {
  name                = var.topic_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  input_schema        = var.input_schema
  tags                = local.merged_tags
}

# ---------------------------------------------------------------------------
# Event subscriptions
# Each subscription counts delivery attempts toward the 100K free operations
# ---------------------------------------------------------------------------

resource "azurerm_eventgrid_event_subscription" "subscriptions" {
  for_each = local.subscriptions

  name  = each.value.name
  scope = azurerm_eventgrid_topic.main.id

  # Webhook endpoint
  dynamic "webhook_endpoint" {
    for_each = each.value.endpoint_type == "webhook" ? [each.value.endpoint_url] : []
    content {
      url = webhook_endpoint.value
    }
  }

  # Azure Function endpoint
  dynamic "azure_function_endpoint" {
    for_each = each.value.endpoint_type == "azure_function" ? [each.value.endpoint_url] : []
    content {
      function_id = azure_function_endpoint.value
    }
  }

  # Subject filter (applied only when prefix or suffix is set)
  dynamic "subject_filter" {
    for_each = (each.value.subject_filter_prefix != "" || each.value.subject_filter_suffix != "") ? [1] : []
    content {
      subject_begins_with = each.value.subject_filter_prefix
      subject_ends_with   = each.value.subject_filter_suffix
    }
  }

  # Event type filter
  included_event_types = length(each.value.included_event_types) > 0 ? each.value.included_event_types : null

  # Retry policy – keep attempts low to minimise wasted free-tier operations
  retry_policy {
    max_delivery_attempts = each.value.max_delivery_attempts
    event_time_to_live    = each.value.event_time_to_live
  }
}

# ---------------------------------------------------------------------------
# Monitoring – publish success count alert
# Always-free: alerts are billed per signal/month; keep minimal to stay free
# ---------------------------------------------------------------------------

resource "azurerm_monitor_metric_alert" "publish_success" {
  count = var.enable_monitoring ? 1 : 0

  name                = "${var.topic_name}-publish-success-alert"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_eventgrid_topic.main.id]
  description         = "Alert when published events approach the 100K free-tier limit."
  severity            = 2
  frequency           = "PT1H"
  window_size         = "P1D"
  tags                = local.merged_tags

  criteria {
    metric_namespace = "Microsoft.EventGrid/topics"
    metric_name      = "PublishSuccessCount"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.publish_alert_threshold
  }

  dynamic "action" {
    for_each = var.action_group_id != "" ? [var.action_group_id] : []
    content {
      action_group_id = action.value
    }
  }
}
