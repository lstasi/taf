# Cloudflare Pages

This module creates a Cloudflare Pages project, optionally linked to a GitHub repository, with an optional custom domain and build configuration.

## What It Creates

- One Cloudflare Pages project.
- An optional GitHub source integration for automatic deployments.
- An optional build configuration for projects with a build step.
- An optional custom domain attached to the project.

## Key Inputs

- `account_id` — Cloudflare account ID (required).
- `project_name` — Name of the Pages project (required).
- `production_branch` — Git branch that triggers production deployments (default: `main`).
- `github_owner` and `github_repo` — Enable GitHub source integration and automatic deployments.
- `build_command` and `build_output_dir` — Configure the build pipeline for projects that require a build step.
- `custom_domain` — Attach a custom domain (e.g. `gestorin.lab86.work`).

## Key Outputs

- `pages_url` — Default `https://<project>.pages.dev` URL.
- `custom_domain` — Custom domain string, or empty string when not configured.
- `project_id` — Internal Cloudflare Pages project ID.
- `project_name` — Pages project name.

## Example

```hcl
module "pages" {
  source = "./cloudflare/pages"

  account_id        = var.cloudflare_account_id
  project_name      = "gestorin"
  production_branch = "main"

  github_owner = "lab86-work"
  github_repo  = "gestorin"

  build_command    = "npm run build"
  build_output_dir = "dist"

  custom_domain = "gestorin.lab86.work"
}

output "site_url" {
  value = module.pages.custom_domain != "" ? "https://${module.pages.custom_domain}" : module.pages.pages_url
}
```

## Always-Free Caveats

- Cloudflare Pages free plan includes unlimited static requests and 500 builds/month. The module itself cannot enforce or monitor build consumption.
- Custom domains require the domain's DNS to be managed through Cloudflare (or a CNAME pointing to `<project>.pages.dev` for external DNS). DNS records are not created by this module.
- GitHub source integration requires the Cloudflare Pages app to be authorised on the GitHub repository before `terraform apply`.
