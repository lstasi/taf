# Azure Event Grid

This module creates an Event Grid custom topic, optional event subscriptions, and optional monitoring alerts.

## What It Creates

- A resource group.
- One Event Grid custom topic.
- Zero or more event subscriptions.
- An optional Azure Monitor metric alert.

## Key Inputs

- `resource_group_name`, `location`, and `topic_name`.
- `input_schema`.
- `subscriptions`: list of endpoint definitions.
- `enable_monitoring`, `action_group_id`, and `publish_alert_threshold`.

## Key Outputs

- `topic_name`
- `topic_id`
- `topic_endpoint`
- `topic_primary_access_key`

## Example

```hcl
module "event_grid" {
  source = "./azure/event-grid"

  resource_group_name = "rg-taf-events"
  location            = "eastus"
  topic_name          = "taf-events"

  subscriptions = [
    {
      name          = "webhook-subscription"
      endpoint_type = "webhook"
      endpoint_url  = "https://example.com/events"
    }
  ]
}
```

## Always-Free Caveats

- Event Grid usage is metered by operations, which the module cannot estimate ahead of time.
- Alert thresholds are advisory only.

## Current Gaps

- No enforcement of the monthly free operations limit.
- No workload simulation or event volume forecasting.
