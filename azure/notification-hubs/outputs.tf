output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "namespace_id" {
  description = "ID of the Notification Hub namespace"
  value       = azurerm_notification_hub_namespace.main.id
}

output "namespace_name" {
  description = "Name of the Notification Hub namespace"
  value       = azurerm_notification_hub_namespace.main.name
}

output "hub_id" {
  description = "ID of the Notification Hub"
  value       = azurerm_notification_hub.main.id
}

output "hub_name" {
  description = "Name of the Notification Hub"
  value       = azurerm_notification_hub.main.name
}
