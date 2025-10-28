# Basic Billing Alerts Example

This example demonstrates the simplest way to set up AWS billing alerts.

## What This Creates

- CloudWatch billing alarm at $10/month threshold
- Warning alarm at $5/month threshold
- SNS topic for notifications
- Email subscription to SNS topic
- AWS Budget with 80%, 90%, and 100% alerts

## Usage

1. Update the email address in `main.tf`:
   ```hcl
   email_address = "your-email@example.com"
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the plan:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

5. **Important**: Check your email and confirm the SNS subscription

## After Deployment

1. Confirm your email subscription (check spam folder)
2. Wait 6-24 hours for billing data to populate
3. Test the alert by publishing to SNS topic:
   ```bash
   aws sns publish \
     --topic-arn $(terraform output -raw sns_topic_arn) \
     --message "Test billing alert" \
     --subject "Test"
   ```

## Cleanup

```bash
terraform destroy
```

## Cost

This example is **completely free** within AWS free tier limits.
