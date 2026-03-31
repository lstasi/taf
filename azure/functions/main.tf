locals {
  merged_tags = merge({ FreeTier = "true" }, var.tags)

  application_stack = (
    var.runtime == "node" ? { node_version = var.runtime_version } :
    var.runtime == "python" ? { python_version = var.runtime_version } :
    var.runtime == "dotnet" ? { dotnet_version = var.runtime_version } :
    var.runtime == "java" ? { java_version = var.runtime_version } :
    var.runtime == "powershell" ? { powershell_core_version = var.runtime_version } :
    {}
  )
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
# Storage account (required by Azure Functions)
# Always-free: 5 GB LRS storage, 20K read/10K write operations
# ---------------------------------------------------------------------------

resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# App Service Plan (Consumption / Serverless)
# Always-free: Y1 SKU — 1M executions/month, 400K GB-seconds/month
# ---------------------------------------------------------------------------

resource "azurerm_service_plan" "main" {
  name                = "${var.function_app_name}-plan"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = var.os_type
  sku_name            = "Y1"

  tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# Linux Function App
# Always-free: 1M executions/month, 400K GB-seconds/month (Consumption plan)
# ---------------------------------------------------------------------------

resource "azurerm_linux_function_app" "main" {
  count = var.os_type == "Linux" ? 1 : 0

  name                       = var.function_app_name
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  storage_account_name       = azurerm_storage_account.main.name
  storage_account_access_key = azurerm_storage_account.main.primary_access_key
  service_plan_id            = azurerm_service_plan.main.id

  app_settings = var.app_settings

  site_config {
    application_stack {
      node_version            = lookup(local.application_stack, "node_version", null)
      python_version          = lookup(local.application_stack, "python_version", null)
      dotnet_version          = lookup(local.application_stack, "dotnet_version", null)
      java_version            = lookup(local.application_stack, "java_version", null)
      powershell_core_version = lookup(local.application_stack, "powershell_core_version", null)
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# Windows Function App
# Always-free: 1M executions/month, 400K GB-seconds/month (Consumption plan)
# ---------------------------------------------------------------------------

resource "azurerm_windows_function_app" "main" {
  count = var.os_type == "Windows" ? 1 : 0

  name                       = var.function_app_name
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  storage_account_name       = azurerm_storage_account.main.name
  storage_account_access_key = azurerm_storage_account.main.primary_access_key
  service_plan_id            = azurerm_service_plan.main.id

  app_settings = var.app_settings

  site_config {
    application_stack {
      node_version            = lookup(local.application_stack, "node_version", null)
      dotnet_version          = lookup(local.application_stack, "dotnet_version", null)
      java_version            = lookup(local.application_stack, "java_version", null)
      powershell_core_version = lookup(local.application_stack, "powershell_core_version", null)
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# Monitoring – Execution count alert (optional)
# Fires when FunctionExecutionCount approaches the free tier limit of 1M/month
# ---------------------------------------------------------------------------

resource "azurerm_monitor_metric_alert" "execution_count" {
  count = var.enable_monitoring ? 1 : 0

  name                = "${var.function_app_name}-execution-count"
  resource_group_name = azurerm_resource_group.main.name
  scopes = [
    var.os_type == "Linux"
    ? azurerm_linux_function_app.main[0].id
    : azurerm_windows_function_app.main[0].id
  ]
  description = "Alert when function execution count exceeds ${var.execution_alert_threshold}"
  severity    = 2
  frequency   = "PT5M"
  window_size = "PT1H"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "FunctionExecutionCount"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.execution_alert_threshold
  }

  dynamic "action" {
    for_each = var.action_group_id != "" ? [var.action_group_id] : []
    content {
      action_group_id = action.value
    }
  }

  tags = local.merged_tags
}
