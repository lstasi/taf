# Azure Service Bus

This module creates a Basic-tier Service Bus namespace, queues, optional queue authorization rules, and optional monitoring alerts.

## What It Creates

- A resource group.
- One Service Bus namespace on the Basic SKU.
- Zero or more queues.
- Optional sender and listener authorization rules per queue.
- An optional queue-depth alert.

## Key Inputs

- `resource_group_name`, `location`, and `namespace_name`.
- `queues`: list of queue definitions.
- `create_authorization_rules`.
- `enable_monitoring`, `action_group_id`, and `queue_depth_alert_threshold`.

## Key Outputs

- `namespace_name`
- `namespace_id`
- `namespace_connection_string`
- `queue_names`
- `queue_ids`

## Example

```hcl
module "service_bus" {
  source = "./azure/service-bus"

  resource_group_name = "rg-taf-bus"
  location            = "eastus"
  namespace_name      = "tafbusns01"

  queues = [
    {
      name                = "jobs"
      default_message_ttl = "P7D"
      max_delivery_count  = 5
    }
  ]
}
```

## Always-Free Caveats

- Queue depth and queue lifetime are workload-dependent and need active monitoring.
- The module uses the Basic SKU, but it cannot meter monthly usage on your behalf.

## Current Gaps

- No forecasting for queue throughput or namespace lifetime.
- No enforcement of the free operating envelope beyond the SKU selection.
