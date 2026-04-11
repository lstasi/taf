output "resource_group_name" {
  description = "Name of the resource group created for billing alert resources"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group created for billing alert resources"
  value       = azurerm_resource_group.main.id
}

output "budget_id" {
  description = "ID of the consumption budget"
  value       = azurerm_consumption_budget_subscription.monthly.id
}

output "budget_name" {
  description = "Name of the consumption budget"
  value       = azurerm_consumption_budget_subscription.monthly.name
}

output "action_group_id" {
  description = "ID of the monitor action group for billing alerts"
  value       = azurerm_monitor_action_group.billing.id
}

output "action_group_name" {
  description = "Name of the monitor action group for billing alerts"
  value       = azurerm_monitor_action_group.billing.name
}

output "anomaly_alert_id" {
  description = "ID of the cost anomaly alert (empty string if disabled)"
  value       = var.enable_anomaly_alerts ? azurerm_cost_anomaly_alert.main[0].id : ""
}
