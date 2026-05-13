output "user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.arn
}

output "user_pool_endpoint" {
  description = "Endpoint of the Cognito User Pool (used as the issuer URL)"
  value       = aws_cognito_user_pool.main.endpoint
}

output "client_id" {
  description = "ID of the Cognito User Pool App Client"
  value       = aws_cognito_user_pool_client.main.id
}

output "jwks_uri" {
  description = "JWKS URI for validating Cognito-issued JWTs (https://<endpoint>/.well-known/jwks.json)"
  value       = "https://${aws_cognito_user_pool.main.endpoint}/.well-known/jwks.json"
}

output "hosted_ui_url" {
  description = "Base URL of the Cognito Hosted UI (empty when enable_hosted_ui = false)"
  value = (
    local.use_prefix_domain
    ? "https://${aws_cognito_user_pool_domain.prefix[0].domain}.auth.${data.aws_region.current.name}.amazoncognito.com"
    : (
      local.use_custom_domain
      ? "https://${var.custom_domain}"
      : ""
    )
  )
}
