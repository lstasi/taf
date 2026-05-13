# AWS Always Free Modules

This directory contains the implemented AWS modules in TAF. The scope is limited to AWS services with perpetual free allowances, not 12-month introductory offers.

## Implemented Modules

| Module | Status | Purpose | Main Caveat |
| --- | --- | --- | --- |
| [billing-alerts](billing-alerts/README.md) | Implemented | CloudWatch billing alarms, SNS notifications, optional AWS Budget | Billing alerts are notifications, not hard spend caps |
| [lambda](lambda/README.md) | Implemented | Lambda function, log group, optional schedule and alarm | You must supply a deployment package |
| [dynamodb](dynamodb/README.md) | Implemented | Provisioned DynamoDB table with optional TTL, GSI, alarms | Free throughput is account-wide, not per table |
| [cloudwatch](cloudwatch/README.md) | Implemented | Log groups, metric alarms, optional dashboard | Module does not cap resource counts to the free allowance |
| [sns](sns/README.md) | Implemented | SNS topic with subscriptions, optional KMS and alarm | Email subscriptions require manual confirmation |
| [sqs](sqs/README.md) | Implemented | SQS queue, optional DLQ and alarms | Request volume is usage-based and not enforced in code |
| [step-functions](step-functions/README.md) | Implemented | State machine, IAM role, logs, optional alarm | State machine definition is not validated before apply |
| [cognito](cognito/README.md) | Implemented | Cognito User Pool, App Client, optional Hosted UI and domain | Free tier is 50,000 MAUs/month; custom domains require ACM and CloudFront |

## Out of Scope

These services are intentionally excluded because the free offer is temporary or too easy to turn into paid usage by accident:

- EC2 instances
- S3 buckets as a general storage module
- RDS
- EBS-focused modules

## Recommended Order

1. Start with [billing-alerts](billing-alerts/README.md) in `us-east-1`.
2. Add one or more service modules.
3. Keep aggregate free-tier limits in mind across the whole AWS account, not just one module.

## Shared Caveats

- Several AWS free-tier limits are account-wide and cannot be enforced inside an individual module.
- Billing metrics are delayed, so alarms are useful but not instantaneous.
- Email-based SNS subscriptions stay inactive until the recipient confirms them.

## Missing Work

- More working examples beyond [billing-alerts/examples/basic](billing-alerts/examples/basic/README.md).
- CI validation and security scanning.
- Stronger validation for aggregate free-tier usage.
