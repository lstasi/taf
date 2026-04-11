output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "function_app_id" {
  description = "ID of the function app"
  value = (
    var.os_type == "Linux"
    ? azurerm_linux_function_app.main[0].id
    : azurerm_windows_function_app.main[0].id
  )
}

output "function_app_name" {
  description = "Name of the function app"
  value = (
    var.os_type == "Linux"
    ? azurerm_linux_function_app.main[0].name
    : azurerm_windows_function_app.main[0].name
  )
}

output "function_app_default_hostname" {
  description = "Default hostname of the function app"
  value = (
    var.os_type == "Linux"
    ? azurerm_linux_function_app.main[0].default_hostname
    : azurerm_windows_function_app.main[0].default_hostname
  )
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.main.id
}

output "service_plan_id" {
  description = "ID of the App Service plan"
  value       = azurerm_service_plan.main.id
}

output "identity_principal_id" {
  description = "Principal ID of the function app system-assigned managed identity"
  value = (
    var.os_type == "Linux"
    ? azurerm_linux_function_app.main[0].identity[0].principal_id
    : azurerm_windows_function_app.main[0].identity[0].principal_id
  )
}
