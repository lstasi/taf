# Oracle Cloud Billing Alerts

This module creates OCI billing notifications using Budgets and Notifications.

## What It Creates

- One Notifications topic.
- Optional email and HTTPS subscriptions.
- One OCI Budget.
- Alert rules for actual, forecast, and optional warning thresholds.

## Key Inputs

- `tenancy_id` and `compartment_id`
- `budget_name`
- `monthly_threshold` and `warning_threshold`
- `email_address` and `https_endpoint`

## Key Outputs

- `budget_id`
- `budget_name`
- `notification_topic_id`
- `notification_topic_name`

## Example

```hcl
module "billing_alerts" {
  source = "./oraclecloud/billing-alerts"

  tenancy_id        = var.tenancy_id
  compartment_id    = var.compartment_id
  monthly_threshold = 10
  warning_threshold = 5
  email_address     = "alerts@example.com"
}
```

## Important Notes

- Alerts are notifications only; they do not block paid resource creation.
- Email subscriptions need the recipient to accept the notification invitation.

## Current Gaps

- Alert rule percentages are less configurable than the AWS and Azure equivalents.
- No hard budget enforcement or automated remediation.
