# AWS Billing Alerts

This module creates AWS billing notifications for the current account. It is the recommended first deployment before using any other AWS module in this repository.

## What It Creates

- An SNS topic for alert delivery.
- A main CloudWatch billing alarm and an optional warning alarm.
- Optional per-service billing alarms from `service_thresholds`.
- Optional AWS Budget notifications.
- Optional KMS encryption for the SNS topic.

## Prerequisites

- Billing alerts must be enabled in the AWS Billing console.
- Billing metrics are published in `us-east-1`, so this module should be planned and applied there.
- If `email_address` is set, the recipient must confirm the SNS subscription before alerts are active.

## Key Inputs

- `monthly_threshold`: main spend threshold in USD.
- `warning_threshold`: lower warning threshold. Set to `0` to disable.
- `email_address`, `sms_number`, `https_endpoint`: optional notification endpoints.
- `create_budget` and `budget_name`: control AWS Budget creation.
- `service_thresholds`: map of AWS service names to per-service cost alarms.

## Key Outputs

- `sns_topic_arn`
- `billing_alarm_arn`
- `warning_alarm_arn`
- `budget_id`
- `service_alarm_arns`

## Example

```hcl
provider "aws" {
  region = "us-east-1"
}

module "billing_alerts" {
  source = "./aws/billing-alerts"

  monthly_threshold = 10
  warning_threshold = 5
  email_address     = "alerts@example.com"
  create_budget     = true

  service_thresholds = {
    "AWS Lambda"         = 1
    "Amazon DynamoDB"    = 1
    "Amazon CloudWatch"  = 1
  }
}
```

## Current Gaps

- Alarms and budgets notify, but they do not stop paid resource creation.
- Billing data is delayed by AWS, so notifications are not real-time.
- The module cannot verify whether other parts of the account are already consuming the same budget or free-tier headroom.
