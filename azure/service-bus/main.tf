# ---------------------------------------------------------------------------
# Local values
# Merge default free-tier tag with user-provided tags
# ---------------------------------------------------------------------------

locals {
  merged_tags = merge({ FreeTier = "true" }, var.tags)
  queue_map   = { for q in var.queues : q.name => q }
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
# Service Bus namespace
# Always-free: Basic tier includes 750 hours/month at no cost
# ---------------------------------------------------------------------------

resource "azurerm_servicebus_namespace" "main" {
  name                = var.namespace_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Basic"
  tags                = local.merged_tags
}

# ---------------------------------------------------------------------------
# Service Bus queues
# Basic tier supports queues (but not topics/subscriptions)
# ---------------------------------------------------------------------------

resource "azurerm_servicebus_queue" "queues" {
  for_each = local.queue_map

  name         = each.value.name
  namespace_id = azurerm_servicebus_namespace.main.id

  default_message_ttl                  = each.value.default_message_ttl
  lock_duration                        = each.value.lock_duration
  max_delivery_count                   = each.value.max_delivery_count
  max_size_in_megabytes                = each.value.max_size_in_megabytes
  dead_lettering_on_message_expiration = each.value.dead_lettering_on_message_expiration
}

# ---------------------------------------------------------------------------
# Authorization rules (optional)
# Per-queue sender and listener rules for least-privilege access
# ---------------------------------------------------------------------------

resource "azurerm_servicebus_queue_authorization_rule" "sender" {
  for_each = var.create_authorization_rules ? local.queue_map : {}

  name     = "${each.key}-sender"
  queue_id = azurerm_servicebus_queue.queues[each.key].id

  send   = true
  listen = false
  manage = false
}

resource "azurerm_servicebus_queue_authorization_rule" "listener" {
  for_each = var.create_authorization_rules ? local.queue_map : {}

  name     = "${each.key}-listener"
  queue_id = azurerm_servicebus_queue.queues[each.key].id

  send   = false
  listen = true
  manage = false
}

# ---------------------------------------------------------------------------
# Monitoring (optional)
# Alert when active message count exceeds threshold
# ---------------------------------------------------------------------------

resource "azurerm_monitor_metric_alert" "active_messages" {
  for_each = var.enable_monitoring ? local.queue_map : {}

  name                = "${var.namespace_name}-${each.key}-active-messages"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_servicebus_namespace.main.id]
  description         = "Alert when active messages in queue ${each.key} exceed ${var.queue_depth_alert_threshold}"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = local.merged_tags

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = "ActiveMessages"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.queue_depth_alert_threshold

    dimension {
      name     = "EntityName"
      operator = "Include"
      values   = [each.key]
    }
  }

  dynamic "action" {
    for_each = var.action_group_id != "" ? [var.action_group_id] : []
    content {
      action_group_id = action.value
    }
  }
}
