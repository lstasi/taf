# ---------------------------------------------------------------------------
# Cloudflare Pages project
# Always-free: unlimited static requests, 500 builds/month
# ---------------------------------------------------------------------------

resource "cloudflare_pages_project" "main" {
  account_id        = var.account_id
  name              = var.project_name
  production_branch = var.production_branch

  # GitHub source integration (optional)
  dynamic "source" {
    for_each = var.github_owner != "" && var.github_repo != "" ? [1] : []
    content {
      type = "github"
      config {
        owner                         = var.github_owner
        repo_name                     = var.github_repo
        production_branch             = var.production_branch
        pr_comments_enabled           = var.pr_comments_enabled
        deployments_enabled           = var.deployments_enabled
        production_deployment_enabled = true
        preview_deployment_setting    = "custom"
        preview_branch_includes       = ["*"]
        preview_branch_excludes       = [var.production_branch]
      }
    }
  }

  # Build configuration (optional)
  build_config {
    build_command   = var.build_command != "" ? var.build_command : null
    destination_dir = var.build_output_dir != "" ? var.build_output_dir : null
  }
}

# ---------------------------------------------------------------------------
# Custom domain (optional)
# Always-free: custom domains are included in the Cloudflare Pages free plan
# ---------------------------------------------------------------------------

resource "cloudflare_pages_domain" "main" {
  count = var.custom_domain != "" ? 1 : 0

  account_id   = var.account_id
  project_name = cloudflare_pages_project.main.name
  domain       = var.custom_domain
}
