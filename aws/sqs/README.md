# AWS SQS

This module creates an SQS queue with optional dead-letter queue support and optional CloudWatch alarms.

## What It Creates

- One primary SQS queue.
- An optional dead-letter queue and redrive policy.
- Optional queue depth alarms for the main queue and the DLQ.

## Key Inputs

- `queue_name`: append `.fifo` to create a FIFO queue.
- `visibility_timeout_seconds`, `message_retention_seconds`, `receive_wait_time_seconds`, and `delay_seconds`.
- `create_dead_letter_queue` and `max_receive_count`.
- `create_cloudwatch_alarm`, `alarm_depth_threshold`, and `alarm_sns_topic_arn`.

## Key Outputs

- `queue_name`
- `queue_arn`
- `queue_url`
- `dlq_arn`
- `queue_depth_alarm_arn`
- `dlq_depth_alarm_arn`

## Example

```hcl
module "queue" {
  source = "./aws/sqs"

  queue_name                 = "taf-work-queue"
  receive_wait_time_seconds  = 10
  create_dead_letter_queue   = true
  max_receive_count          = 5
  create_cloudwatch_alarm    = true
  alarm_depth_threshold      = 100
}
```

## Always-Free Caveats

- SQS free usage is request-based and shared across sends, receives, deletes, and empty receives.
- Long polling reduces wasted receive calls and helps stay in the free allowance.
- FIFO behavior is inferred from the queue name ending in `.fifo`.

## Current Gaps

- The module cannot estimate your workload's request volume ahead of time.
- It does not enforce account-wide SQS usage against the monthly free allowance.
