output "pages_url" {
  description = "Default Cloudflare Pages URL for the project (https://<project>.pages.dev)"
  value       = "https://${cloudflare_pages_project.main.name}.pages.dev"
}

output "custom_domain" {
  description = "Custom domain attached to the Pages project. Empty string when no custom domain is configured"
  value       = var.custom_domain != "" ? cloudflare_pages_domain.main[0].domain : ""
}

output "project_id" {
  description = "Internal ID of the Cloudflare Pages project"
  value       = cloudflare_pages_project.main.id
}

output "project_name" {
  description = "Name of the Cloudflare Pages project"
  value       = cloudflare_pages_project.main.name
}
