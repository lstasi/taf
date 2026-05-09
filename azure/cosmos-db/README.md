# Azure Cosmos DB

This module creates a Cosmos DB SQL API account with free tier enabled, a database, optional containers, and optional monitoring alerts.

## What It Creates

- A resource group.
- One Cosmos DB account with free tier enabled.
- One SQL database.
- Zero or more SQL containers.
- Optional RU and storage alerts.

## Key Inputs

- `resource_group_name` and `location`.
- `account_name` and optional `database_name`.
- `throughput`: validated for the free-tier range.
- `containers`: list of container definitions.
- `enable_monitoring` and `action_group_id`.

## Key Outputs

- `account_name`
- `account_endpoint`
- `primary_connection_string`
- `database_name`
- `database_id`

## Example

```hcl
module "cosmos" {
  source = "./azure/cosmos-db"

  resource_group_name = "rg-taf-data"
  location            = "eastus"
  account_name        = "tafcosmosacct01"
  database_name       = "appdb"
  throughput          = 1000

  containers = [
    {
      name               = "items"
      partition_key_path = "/id"
    }
  ]
}
```

## Always-Free Caveats

- Azure permits only one free-tier Cosmos DB account per subscription.
- RU and storage usage are workload-driven and must be monitored over time.

## Current Gaps

- The module cannot detect whether the subscription has already used its free-tier Cosmos DB slot.
- It does not predict real RU consumption from your application workload.
