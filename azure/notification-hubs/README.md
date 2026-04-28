# Azure Notification Hubs

This module creates an Azure Notification Hubs namespace and hub on the free SKU, with optional platform credentials and an optional listen rule.

## What It Creates

- A resource group.
- One Notification Hubs namespace on the free tier.
- One Notification Hub.
- Optional APNs and FCM credentials.
- An optional listen-only authorization rule.

## Key Inputs

- `resource_group_name` and `location`.
- `namespace_name` and `hub_name`.
- `apns_credential` and `gcm_credential` when platform credentials are needed.
- `create_listen_rule`.

## Key Outputs

- `namespace_name`
- `namespace_id`
- `hub_name`
- `hub_id`

## Example

```hcl
module "notification_hub" {
  source = "./azure/notification-hubs"

  resource_group_name = "rg-taf-push"
  location            = "eastus"
  namespace_name      = "tafpushns"
  hub_name            = "tafpushhub"
  create_listen_rule  = true
}
```

## Always-Free Caveats

- Free-tier suitability depends on push volume and supported client platforms.
- Platform credentials are external secrets and need their own rotation process.

## Current Gaps

- No alerting or usage forecasting for push volume.
- No built-in secret rotation for APNs or FCM credentials.
