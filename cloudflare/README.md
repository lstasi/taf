# Cloudflare

Cloudflare modules for always-free resources.

## Implemented Modules

| Module | Status | Notes |
| --- | --- | --- |
| `pages` | Implemented | Pages project with optional GitHub source integration, build config, and custom domain |

## Planned Scope

- DNS
- CDN configuration
- Workers
- Universal SSL guidance

## Notes

- Cloudflare Pages free plan includes unlimited static requests and 500 builds/month.
- Custom domains require DNS to be managed through Cloudflare, or a CNAME pointing to the `<project>.pages.dev` subdomain.
- GitHub source integration requires the Cloudflare Pages app to be authorised on the GitHub account before `terraform apply`.
