# AWS CloudWatch

This module creates CloudWatch log groups, metric alarms, and an optional dashboard from simple maps.

## What It Creates

- Any number of log groups defined in `log_groups`.
- Any number of metric alarms defined in `alarms`.
- One optional dashboard when `dashboard_name` is set.

## Key Inputs

- `name_prefix`: prefix for alarm names.
- `log_groups`: map of log group names to retention configuration.
- `alarms`: map of alarm definitions including metric, namespace, threshold, and optional SNS target.
- `dashboard_name` and `dashboard_body`: optional dashboard definition.

## Key Outputs

- `log_group_names`
- `log_group_arns`
- `alarm_names`
- `alarm_arns`
- `dashboard_arn`

## Example

```hcl
module "cloudwatch" {
  source = "./aws/cloudwatch"

  name_prefix = "taf"

  log_groups = {
    "/aws/lambda/demo" = {
      retention_in_days = 14
    }
  }

  alarms = {
    lambda-errors = {
      namespace   = "AWS/Lambda"
      metric_name = "Errors"
      statistic   = "Sum"
      period      = 300
      threshold   = 1
    }
  }
}
```

## Always-Free Caveats

- AWS always-free usage is limited to 10 alarms, 10 custom metrics, 3 dashboards, and 5 GB of log ingestion per month.
- This module does not enforce those counts. If you pass large maps, Terraform will create the resources anyway.

## Current Gaps

- No validation for alarm count, custom metric count, or dashboard size.
- No account-wide awareness of existing CloudWatch usage outside this module.
