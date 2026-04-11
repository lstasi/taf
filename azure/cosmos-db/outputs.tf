output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "account_id" {
  description = "ID of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.id
}

output "account_name" {
  description = "Name of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.name
}

output "account_endpoint" {
  description = "Endpoint URL of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.endpoint
}

output "primary_key" {
  description = "Primary key for the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.primary_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "Primary connection string for the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.primary_sql_connection_string
  sensitive   = true
}

output "database_name" {
  description = "Name of the SQL database"
  value       = azurerm_cosmosdb_sql_database.main.name
}

output "database_id" {
  description = "ID of the SQL database"
  value       = azurerm_cosmosdb_sql_database.main.id
}
