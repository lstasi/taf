# Cloudflare Always Free Resources

Documentation and (planned) Terraform modules for deploying Cloudflare **always-free** resources.

## 🎯 Focus: Always Free Only

This project focuses **exclusively on Cloudflare resources that are perpetually free** (not paid add-ons or usage beyond free limits).

**Current Phase**: Documentation

## 📦 Always Free Resources (Documented)

### DNS & CDN
- **dns**: Authoritative DNS management
  - Limit: Unlimited DNS queries (always free)
  - Status: 📝 Documentation phase

- **cdn**: Global CDN and caching
  - Limit: Unlimited bandwidth on free plan (fair use and product limits apply)
  - Status: 📝 Documentation phase

### Compute (Edge)
- **workers**: Cloudflare Workers
  - Limit: 100,000 requests/day (always free)
  - Status: 📝 Documentation phase

- **pages**: Cloudflare Pages
  - Limit: Unlimited static sites/projects (build/runtime limits apply)
  - Status: 📝 Documentation phase

### Security
- **ssl**: Universal SSL certificates
  - Limit: Included on free plan for proxied domains
  - Status: 📝 Documentation phase

## ⚠️ Always Free Limits

| Service | Always Free Limit | Perpetual | Notes |
|---------|-------------------|-----------|-------|
| **DNS** | Unlimited queries | ✅ Yes | Zone/domain registration is separate |
| **CDN** | Unlimited bandwidth | ✅ Yes | Subject to free plan capabilities |
| **Workers** | 100k requests/day | ✅ Yes | Daily reset; CPU/runtime limits apply |
| **Pages** | Unlimited projects | ✅ Yes | Build minutes and functions limits apply |
| **Universal SSL** | Included | ✅ Yes | For proxied records on supported domains |

## ❌ Not Included in Always-Free Scope

- Paid Cloudflare plan features (Pro/Business/Enterprise-only)
- Usage above free limits for Workers/Pages add-on features
- Domain registration and renewal costs (handled by registrar)

## 🛡️ Billing Protection Strategy

1. Start on Cloudflare Free plan only
2. Monitor Workers and Pages usage weekly
3. Avoid enabling paid add-ons unless explicitly needed
4. Keep DNS-only or proxied settings intentional per record
5. Review Cloudflare dashboard usage before expanding workloads

## 📋 Prerequisites

- Terraform >= 1.0.0
- Cloudflare account on Free plan
- API token with least required permissions
- Cloudflare Zone ID for target domain(s)

## 🔒 Security Best Practices

1. Never commit Cloudflare API tokens
2. Use scoped API tokens (least privilege), not global keys
3. Store secrets in secure secret managers or environment variables
4. Enable and keep SSL/TLS mode configured correctly
5. Use Cloudflare Access or WAF features where available in free tier

## 📚 Additional Resources

- [Cloudflare Pricing](https://www.cloudflare.com/plans/)
- [Cloudflare Free Plan Details](https://www.cloudflare.com/plans/free/)
- [Cloudflare Workers Pricing](https://developers.cloudflare.com/workers/platform/pricing/)
- [Cloudflare Pages Pricing](https://developers.cloudflare.com/pages/platform/pricing/)
- [Terraform Cloudflare Provider](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs)

## 🗺️ Roadmap

See [TODO.md](../TODO.md) for detailed implementation status.
