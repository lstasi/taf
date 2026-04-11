output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "namespace_id" {
  description = "ID of the Service Bus namespace"
  value       = azurerm_servicebus_namespace.main.id
}

output "namespace_name" {
  description = "Name of the Service Bus namespace"
  value       = azurerm_servicebus_namespace.main.name
}

output "namespace_connection_string" {
  description = "Primary connection string for the Service Bus namespace"
  value       = azurerm_servicebus_namespace.main.default_primary_connection_string
  sensitive   = true
}

output "queue_ids" {
  description = "Map of queue name to queue ID"
  value       = { for k, v in azurerm_servicebus_queue.queues : k => v.id }
}

output "queue_names" {
  description = "List of created queue names"
  value       = [for k, v in azurerm_servicebus_queue.queues : v.name]
}
