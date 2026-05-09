# Basic AWS Billing Alerts Example

This example wires the billing-alerts module with one email recipient and default warning thresholds.

## What It Demonstrates

- CloudWatch billing alarm creation in `us-east-1`
- SNS topic creation for alert delivery
- AWS Budget creation
- Email-based alert delivery

## Before You Apply

1. Enable billing alerts in the AWS Billing console.
2. Replace the example email address in `main.tf`.
3. Make sure your AWS provider is using `us-east-1`.

## After You Apply

1. Confirm the SNS subscription from the email you receive.
2. Wait for AWS billing metrics to populate.
3. Optionally publish a test message to the topic.

## Current Limitation

This example proves alert wiring only. It does not simulate spend or verify end-to-end alarm firing.
