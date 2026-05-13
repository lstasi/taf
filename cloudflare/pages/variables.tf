variable "account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "project_name" {
  description = "Name of the Cloudflare Pages project"
  type        = string
}

variable "production_branch" {
  description = "Git branch that triggers production deployments"
  type        = string
  default     = "main"
}

variable "github_owner" {
  description = "GitHub organisation or username that owns the repository. Leave empty to skip GitHub source integration"
  type        = string
  default     = ""
}

variable "github_repo" {
  description = "GitHub repository name (without the owner prefix). Required when github_owner is set"
  type        = string
  default     = ""
}

variable "pr_comments_enabled" {
  description = "Post Cloudflare Pages deployment comments on pull requests. Only used when GitHub source integration is enabled"
  type        = bool
  default     = true
}

variable "deployments_enabled" {
  description = "Enable automatic deployments from the connected GitHub repository. Only used when GitHub source integration is enabled"
  type        = bool
  default     = true
}

variable "build_command" {
  description = "Build command to run before deploying (e.g. npm run build). Leave empty for projects with a pre-built output"
  type        = string
  default     = ""
}

variable "build_output_dir" {
  description = "Directory containing the built static assets to deploy (e.g. dist, build, public). Leave empty for projects that deploy from the repository root"
  type        = string
  default     = ""
}

variable "custom_domain" {
  description = "Custom domain to attach to the Pages project (e.g. example.com). Leave empty to use only the default pages.dev subdomain"
  type        = string
  default     = ""
}
