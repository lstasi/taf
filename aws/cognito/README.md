# AWS Cognito User Pool

This module creates a Cognito User Pool with a public App Client (no client secret) suitable for SPA or static-frontend authentication, plus an optional Hosted UI domain.

## What It Creates

- One Cognito User Pool with email sign-in and configurable password policy.
- One App Client (public, no secret) with SRP and refresh-token auth flows.
- Optional Cognito-managed domain for the Hosted UI (free subdomain of `amazoncognito.com`).
- Optional custom domain for the Hosted UI (requires an ACM certificate in `us-east-1`).

## Key Inputs

| Name | Description | Default |
|---|---|---|
| `name` | Base name for the user pool | *(required)* |
| `allow_self_registration` | Allow users to register themselves | `true` |
| `auto_verify_email` | Automatically verify the email attribute | `true` |
| `mfa_configuration` | MFA setting: `OFF`, `ON`, or `OPTIONAL` | `OFF` |
| `password_minimum_length` | Minimum password length | `8` |
| `callback_urls` | OAuth callback URLs for the app client | `[]` |
| `logout_urls` | OAuth logout URLs for the app client | `[]` |
| `allowed_oauth_flows` | OAuth flows to enable | `["code"]` |
| `allowed_oauth_scopes` | OAuth scopes to allow | `["openid","email","profile"]` |
| `token_validity_hours` | Access/ID token validity in hours | `1` |
| `refresh_token_validity_days` | Refresh token validity in days | `30` |
| `enable_hosted_ui` | Create a domain and enable the Hosted UI | `false` |
| `domain_prefix` | Cognito-managed domain prefix | `""` |
| `custom_domain` | Custom domain for the Hosted UI | `""` |
| `custom_domain_certificate_arn` | ACM certificate ARN for the custom domain | `""` |
| `tags` | Additional tags for all resources | `{}` |

## Key Outputs

| Name | Description |
|---|---|
| `user_pool_id` | ID of the Cognito User Pool |
| `user_pool_arn` | ARN of the Cognito User Pool |
| `user_pool_endpoint` | Issuer URL for the user pool |
| `client_id` | ID of the App Client |
| `jwks_uri` | JWKS URI for JWT verification |
| `hosted_ui_url` | Base URL of the Hosted UI (empty if `enable_hosted_ui = false`) |

## Examples

### Minimal — user pool and app client only

```hcl
module "cognito" {
  source = "./aws/cognito"

  name = "my-app"
}
```

### With Hosted UI on a Cognito-managed domain

```hcl
module "cognito" {
  source = "./aws/cognito"

  name          = "my-app"
  enable_hosted_ui = true
  domain_prefix    = "my-app-auth"

  callback_urls = ["https://my-app.example.com/callback"]
  logout_urls   = ["https://my-app.example.com/logout"]
}
```

### With a custom domain

```hcl
module "cognito" {
  source = "./aws/cognito"

  name          = "my-app"
  enable_hosted_ui              = true
  custom_domain                 = "auth.example.com"
  custom_domain_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abc"

  callback_urls = ["https://my-app.example.com/callback"]
  logout_urls   = ["https://my-app.example.com/logout"]
}
```

## Always-Free Caveats

- Cognito free tier covers **50,000 MAUs per month**. This module cannot enforce that limit.
- The Cognito-managed domain (`amazoncognito.com`) is free. Custom domains require an ACM certificate and an associated CloudFront distribution which may incur costs.
- MFA with SMS (`ON` or `OPTIONAL`) requires Amazon SNS and may incur SMS charges. TOTP-based MFA is free.

## Current Gaps

- The module does not configure advanced security features (anomaly detection, adaptive authentication) — these require the Cognito advanced security add-on which is not free.
- SMS-based MFA is not configured in this module. Use `mfa_configuration = "OFF"` (the default) to stay on the free tier.
- No resource server or custom OAuth scopes are defined. These can be added as separate resources referencing `module.cognito.user_pool_id`.
