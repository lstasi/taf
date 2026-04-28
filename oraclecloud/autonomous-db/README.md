# Oracle Cloud Autonomous Database

This module creates a free-tier Autonomous Database with optional monitoring alarms.

## What It Creates

- One Autonomous Database with `is_free_tier = true`.
- Optional monitoring alarms when `notification_topic_id` is provided.

## Key Inputs

- `compartment_id`
- `db_name` and optional `display_name`
- `db_workload`
- `admin_password`
- `whitelisted_ips`
- `notification_topic_id`

## Key Outputs

- `autonomous_database_id`
- `autonomous_database_name`
- `db_workload`
- `connection_strings`
- `service_console_url`
- `is_free_tier`

## Example

```hcl
module "autonomous_db" {
  source = "./oraclecloud/autonomous-db"

  compartment_id = var.compartment_id
  db_name        = "TAFAPPDB"
  db_workload    = "OLTP"
  admin_password = var.autonomous_admin_password
}
```

## Always-Free Caveats

- OCI allows only two always-free Autonomous Databases per tenancy.
- The module correctly pins the database to free-tier settings, but it cannot reserve tenancy-wide capacity for you.

## Current Gaps

- No detection of existing free-tier Autonomous Databases elsewhere in the tenancy.
- No automated wallet download or secret distribution workflow.
