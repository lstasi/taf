# ---------------------------------------------------------------------------
# Resource group outputs
# ---------------------------------------------------------------------------

output "resource_group_name" {
  description = "Name of the resource group containing Event Grid resources."
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group containing Event Grid resources."
  value       = azurerm_resource_group.main.id
}

# ---------------------------------------------------------------------------
# Event Grid topic outputs
# ---------------------------------------------------------------------------

output "topic_id" {
  description = "ID of the Event Grid custom topic."
  value       = azurerm_eventgrid_topic.main.id
}

output "topic_name" {
  description = "Name of the Event Grid custom topic."
  value       = azurerm_eventgrid_topic.main.name
}

output "topic_endpoint" {
  description = "Endpoint URL for publishing events to the custom topic."
  value       = azurerm_eventgrid_topic.main.endpoint
}

output "topic_primary_access_key" {
  description = "Primary access key for the Event Grid custom topic."
  value       = azurerm_eventgrid_topic.main.primary_access_key
  sensitive   = true
}

output "topic_secondary_access_key" {
  description = "Secondary access key for the Event Grid custom topic."
  value       = azurerm_eventgrid_topic.main.secondary_access_key
  sensitive   = true
}
