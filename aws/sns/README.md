# AWS SNS

This module creates an SNS topic with optional email, HTTPS, SQS, and Lambda subscriptions, plus optional KMS encryption and an optional failure alarm.

## What It Creates

- One SNS topic.
- Optional subscriptions across multiple protocols.
- Optional customer-managed KMS key for topic encryption.
- Optional CloudWatch alarm for failed deliveries.

## Key Inputs

- `topic_name`: append `.fifo` to create a FIFO topic.
- `email_subscriptions`, `https_subscriptions`, `sqs_subscriptions`, `lambda_subscriptions`.
- `enable_encryption`.
- `delivery_policy` for HTTP endpoints.
- `create_cloudwatch_alarm` and `alarm_sns_topic_arn`.

## Key Outputs

- `topic_name`
- `topic_arn`
- `kms_key_id`
- `kms_key_arn`
- `failure_alarm_arn`

## Example

```hcl
module "notifications" {
  source = "./aws/sns"

  topic_name           = "taf-notifications"
  email_subscriptions  = ["alerts@example.com"]
  https_subscriptions  = ["https://example.com/webhook"]
  enable_encryption    = true
  create_cloudwatch_alarm = true
}
```

## Always-Free Caveats

- Email subscriptions require manual confirmation.
- FIFO behavior is inferred from the topic name ending in `.fifo`.
- Delivery volume limits are usage-based and are not enforced by the module.

## Current Gaps

- No validation that `.fifo` naming matches user intent beyond the naming convention itself.
- No enforcement of total deliveries against the SNS always-free allowance.
