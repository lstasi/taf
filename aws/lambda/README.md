# AWS Lambda

This module creates a single Lambda function with a log group, an execution role when needed, an optional EventBridge schedule, and an optional error alarm.

## What It Creates

- One Lambda function.
- A CloudWatch log group for the function.
- An IAM role when `iam_role_arn` is not supplied.
- Optional EventBridge schedule and invoke permission.
- Optional CloudWatch error alarm.

## Key Inputs

- `function_name`, `runtime`, `handler`.
- Either `filename` or `s3_bucket` plus `s3_key` for the deployment package.
- `memory_size`, `timeout`, `environment_variables`.
- `iam_role_arn` or `additional_policy_arns`.
- `schedule_expression` for periodic execution.

## Key Outputs

- `function_name`
- `function_arn`
- `iam_role_arn`
- `log_group_name`
- `error_alarm_arn`
- `schedule_rule_arn`

## Example

```hcl
module "lambda" {
  source = "./aws/lambda"

  function_name     = "taf-demo"
  runtime           = "python3.12"
  handler           = "index.handler"
  filename          = "build/lambda.zip"
  source_code_hash  = filebase64sha256("build/lambda.zip")
  memory_size       = 256
  timeout           = 30
  schedule_expression = "rate(1 day)"

  environment_variables = {
    STAGE = "dev"
  }
}
```

## Always-Free Caveats

- AWS Lambda free usage is based on monthly requests and GB-seconds, which this module cannot predict.
- CloudWatch log ingestion counts separately against the CloudWatch free allowance.

## Current Gaps

- The module does not currently validate that a deployment package source is provided before apply.
- It does not estimate or enforce monthly usage against the Lambda free allowance.
