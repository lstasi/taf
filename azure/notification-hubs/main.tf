locals {
  merged_tags = merge({ FreeTier = "true" }, var.tags)
}

# ---------------------------------------------------------------------------
# Resource group
# Always-free: resource groups have no cost
# ---------------------------------------------------------------------------

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# Notification Hub namespace
# Free tier: 1M pushes/month, 500 active devices, no SLA
# ---------------------------------------------------------------------------

resource "azurerm_notification_hub_namespace" "main" {
  name                = var.namespace_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  namespace_type      = "NotificationHub"
  sku_name            = "Free"

  tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# Notification Hub
# Free tier: 1M pushes/month, 500 active devices
# ---------------------------------------------------------------------------

resource "azurerm_notification_hub" "main" {
  name                = var.hub_name
  namespace_name      = azurerm_notification_hub_namespace.main.name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  dynamic "apns_credential" {
    for_each = var.apns_credential != null ? [var.apns_credential] : []
    content {
      application_mode = apns_credential.value.application_mode
      bundle_id        = apns_credential.value.bundle_id
      key_id           = apns_credential.value.key_id
      team_id          = apns_credential.value.team_id
      token            = apns_credential.value.token
    }
  }

  dynamic "gcm_credential" {
    for_each = var.gcm_credential != null ? [var.gcm_credential] : []
    content {
      api_key = gcm_credential.value.api_key
    }
  }

  tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# Listen-only authorization rule (optional)
# Used by client applications to register for and receive push notifications
# ---------------------------------------------------------------------------

resource "azurerm_notification_hub_authorization_rule" "listen" {
  count = var.create_listen_rule ? 1 : 0

  name                  = "${var.hub_name}-listen"
  notification_hub_name = azurerm_notification_hub.main.name
  namespace_name        = azurerm_notification_hub_namespace.main.name
  resource_group_name   = azurerm_resource_group.main.name

  listen = true
  send   = false
  manage = false
}
