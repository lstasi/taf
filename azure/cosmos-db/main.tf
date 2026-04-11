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
# Cosmos DB Account (Free Tier)
# Always-free: 1,000 RU/s + 25 GB storage (one free tier account per subscription)
# ---------------------------------------------------------------------------

resource "azurerm_cosmosdb_account" "main" {
  name                = var.account_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  free_tier_enabled   = true

  automatic_failover_enabled = false

  consistency_policy {
    consistency_level = var.consistency_level
  }

  geo_location {
    location          = azurerm_resource_group.main.location
    failover_priority = 0
  }

  tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# Cosmos DB SQL Database (shared throughput)
# Throughput is capped at 1,000 RU/s to stay within the free tier
# ---------------------------------------------------------------------------

resource "azurerm_cosmosdb_sql_database" "main" {
  name                = var.database_name
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
  throughput          = var.throughput
}

# ---------------------------------------------------------------------------
# Cosmos DB SQL Containers
# Containers share the database-level throughput provisioned above
# ---------------------------------------------------------------------------

resource "azurerm_cosmosdb_sql_container" "containers" {
  for_each = { for c in var.containers : c.name => c }

  name                = each.value.name
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_sql_database.main.name
  partition_key_paths = [each.value.partition_key_path]

  dynamic "unique_key" {
    for_each = each.value.unique_keys
    content {
      paths = unique_key.value
    }
  }
}

# ---------------------------------------------------------------------------
# Monitoring – RU consumption alert (optional)
# Fires when NormalizedRUConsumption exceeds the configured threshold
# ---------------------------------------------------------------------------

resource "azurerm_monitor_metric_alert" "ru_consumption" {
  count = var.enable_monitoring ? 1 : 0

  name                = "${var.account_name}-ru-consumption"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_cosmosdb_account.main.id]
  description         = "Alert when Cosmos DB normalized RU consumption exceeds ${var.ru_alert_threshold}%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.DocumentDB/databaseAccounts"
    metric_name      = "NormalizedRUConsumption"
    aggregation      = "Maximum"
    operator         = "GreaterThan"
    threshold        = var.ru_alert_threshold
  }

  dynamic "action" {
    for_each = var.action_group_id != "" ? [var.action_group_id] : []
    content {
      action_group_id = action.value
    }
  }

  tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# Monitoring – Storage alert (optional)
# Fires when DataUsage exceeds the configured threshold (converted to bytes)
# ---------------------------------------------------------------------------

resource "azurerm_monitor_metric_alert" "storage" {
  count = var.enable_monitoring ? 1 : 0

  name                = "${var.account_name}-storage"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_cosmosdb_account.main.id]
  description         = "Alert when Cosmos DB storage exceeds ${var.storage_alert_threshold_gb} GB"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.DocumentDB/databaseAccounts"
    metric_name      = "DataUsage"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.storage_alert_threshold_gb * 1073741824
  }

  dynamic "action" {
    for_each = var.action_group_id != "" ? [var.action_group_id] : []
    content {
      action_group_id = action.value
    }
  }

  tags = local.merged_tags
}
