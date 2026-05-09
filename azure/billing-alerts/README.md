# Azure Billing Alerts

This module creates subscription-level cost alerts using Azure Cost Management and Azure Monitor.

## What It Creates

- A resource group for alert-related resources.
- An action group with email and optional webhook receivers.
- A subscription budget with one or more threshold notifications.
- An optional cost anomaly alert.

## Key Inputs

- `resource_group_name` and `location`.
- `monthly_budget` and `warning_threshold`.
- `email_addresses` and optional `webhook_url`.
- `alert_thresholds`: list of threshold objects.
- `budget_start_date` and `budget_end_date`.

## Key Outputs

- `resource_group_name`
- `budget_id`
- `action_group_id`
- `anomaly_alert_id`

## Example

```hcl
module "billing_alerts" {
  source = "./azure/billing-alerts"

  resource_group_name = "rg-taf-billing"
  location            = "eastus"
  monthly_budget      = 10
  warning_threshold   = 5
  email_addresses     = ["alerts@example.com"]

  budget_start_date = "2026-01-01T00:00:00Z"
  budget_end_date   = "2026-12-31T23:59:59Z"
}
```

## Important Notes

- Budgets and anomaly alerts notify, but they do not prevent paid resource creation.
- Set `budget_start_date` and `budget_end_date` explicitly. The current module defaults are static dates and should not be relied on for long-lived deployments.

## Current Gaps

- No hard enforcement of subscription spending.
- Budget effectiveness depends on keeping the configured time window current.
