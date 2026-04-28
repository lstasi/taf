# AWS Step Functions

This module creates a Step Functions state machine with logging, an execution role, optional least-privilege service access, and an optional failure alarm.

## What It Creates

- One state machine.
- A CloudWatch log group when logging is enabled.
- An IAM role when `iam_role_arn` is not supplied.
- Optional IAM permissions for Lambda, DynamoDB, SNS, and SQS integrations.
- Optional CloudWatch alarm for failed executions.

## Key Inputs

- `name`
- `definition`: Amazon States Language JSON definition.
- `iam_role_arn` or `additional_policy_arns`.
- `lambda_arns`, `dynamodb_table_arns`, `sns_topic_arns`, `sqs_queue_arns`.
- `enable_logging`, `log_level`, and `log_retention_days`.

## Key Outputs

- `state_machine_name`
- `state_machine_arn`
- `iam_role_arn`
- `log_group_name`
- `failure_alarm_arn`

## Example

```hcl
module "workflow" {
  source = "./aws/step-functions"

  name = "taf-workflow"
  definition = jsonencode({
    StartAt = "Done"
    States = {
      Done = {
        Type = "Succeed"
      }
    }
  })

  enable_logging = true
}
```

## Always-Free Caveats

- Step Functions always-free usage is limited by monthly state transitions.
- This module does not estimate transition volume from your workflow definition.
- CloudWatch logging adds separate CloudWatch usage.

## Current Gaps

- The module does not validate the state machine definition beyond what the provider accepts at apply time.
- No guardrail exists for monthly transition volume.
