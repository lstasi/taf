output "application_id" {
  description = "OCID of the Function Application"
  value       = oci_functions_application.main.id
}

output "application_display_name" {
  description = "Display name of the Function Application"
  value       = oci_functions_application.main.display_name
}

output "function_ids" {
  description = "Map of function name to OCID"
  value       = { for k, f in oci_functions_function.functions : k => f.id }
}

output "api_gateway_id" {
  description = "OCID of the API Gateway (empty if not created)"
  value       = var.create_api_gateway ? oci_apigateway_gateway.main[0].id : ""
}

output "api_gateway_endpoint" {
  description = "Hostname of the API Gateway endpoint (empty if not created)"
  value       = var.create_api_gateway ? oci_apigateway_gateway.main[0].hostname : ""
}

output "api_deployment_endpoint" {
  description = "Full URL prefix for API Gateway routes (empty if not created)"
  value       = var.create_api_gateway && length(var.api_routes) > 0 ? "https://${oci_apigateway_gateway.main[0].hostname}/v1" : ""
}
