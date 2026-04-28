# AWS DynamoDB

This module creates a provisioned-capacity DynamoDB table with optional TTL, global secondary indexes, server-side encryption, and CloudWatch alarms.

## What It Creates

- One DynamoDB table in provisioned mode.
- Optional TTL configuration.
- Optional global secondary indexes.
- Optional read and write capacity alarms.
- Optional AWS-managed server-side encryption.

## Key Inputs

- `table_name`, `hash_key`, and optional `range_key`.
- `read_capacity` and `write_capacity`.
- `global_secondary_indexes`: list of GSI definitions.
- `ttl_attribute`: enables TTL when set.
- `create_cloudwatch_alarm` and `alarm_sns_topic_arn`.

## Key Outputs

- `table_name`
- `table_arn`
- `table_stream_arn`
- `read_capacity_alarm_arn`
- `write_capacity_alarm_arn`

## Example

```hcl
module "table" {
  source = "./aws/dynamodb"

  table_name     = "taf-items"
  hash_key       = "id"
  hash_key_type  = "S"
  read_capacity  = 5
  write_capacity = 5
  ttl_attribute  = "expires_at"
}
```

## Always-Free Caveats

- DynamoDB always-free throughput is 25 RCU and 25 WCU across the AWS account, not per table.
- GSI capacity also consumes the same provisioned-capacity budget.
- Storage is likewise shared at the account level.

## Current Gaps

- The module validates only the table inputs it can see.
- It cannot detect other DynamoDB tables or GSIs already consuming the free allowance.
