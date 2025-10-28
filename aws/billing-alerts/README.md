# AWS Billing Alerts Documentation

**⚠️ CRITICAL: Always configure billing protection FIRST before deploying any AWS resources!**

**Current Phase**: Documentation

This document describes strategies and patterns for monitoring AWS costs when using always-free resources. While always-free resources should not incur charges within their limits, billing protection is essential to catch misconfigurations or accidental usage of non-free resources.

## Why Billing Protection Matters

Even when using only always-free resources:
- Misconfigurations can deploy non-free resources
- Exceeding always-free limits incurs charges
- Accidental deployments can be costly
- Early detection prevents bill shock

## Always-Free AWS Monitoring Resources

### CloudWatch (Always Free)
- **10 alarms** per month (always free)
- **10 metrics** per month (always free)
- **5GB log ingestion** per month (always free)

### SNS (Always Free)
- **1,000 email deliveries** per month (always free)
- **1M mobile push notifications** per month (always free)
- **100,000 HTTP/S deliveries** per month (always free)

### AWS Budgets
- **First 2 budgets** are free (any number of alarms)
- Additional budgets: $0.02/day each

## Recommended Billing Protection Strategy

### 1. CloudWatch Billing Alarms (Always Free)

### Advanced Example

```hcl
module "billing_alerts" {
  source = "./aws/billing-alerts"
  
  # Alert configuration
  alarm_name        = "my-billing-alert"
  monthly_threshold = 10.0
  warning_threshold = 5.0
  currency          = "USD"
  
  # Notification channels
  email_address  = "alerts@example.com"
  sms_number     = "+1234567890"  # E.164 format
  https_endpoint = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
  
  # SNS configuration
  sns_topic_name         = "my-billing-alerts"
  send_ok_notifications  = true
  enable_encryption      = true
  
  # Budget configuration
  create_budget = true
  budget_name   = "monthly-aws-budget"
  
  # Per-service thresholds
  service_thresholds = {
    "Amazon Elastic Compute Cloud - Compute" = 5.0
    "Amazon Simple Storage Service"          = 2.0
    "Amazon Relational Database Service"     = 3.0
  }
  
  # Tags
  tags = {
    Environment = "production"
    Project     = "free-tier-monitoring"
    Owner       = "devops-team"
  }
}
```

### Minimal Example (No Email)

```hcl
module "billing_alerts" {
  source = "./aws/billing-alerts"
  
  monthly_threshold = 10.0
  # email_address left empty - you'll need to manually subscribe to SNS
}

# Output the SNS topic ARN to manually subscribe
output "sns_topic_arn" {
  value = module.billing_alerts.sns_topic_arn
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Prerequisites

### 1. Enable Billing Alerts in AWS Console

**Important:** Billing alarms require billing alerts to be enabled in your AWS account.

1. Sign in to AWS Management Console
2. Go to **Billing and Cost Management**
3. Choose **Billing Preferences**
4. Check **Receive Billing Alerts**
5. Click **Save preferences**

This is a one-time setup per AWS account.

### 2. Use us-east-1 Region

CloudWatch billing metrics are only available in the `us-east-1` region. Make sure your provider is configured for this region:

```hcl
provider "aws" {
  region = "us-east-1"
}

module "billing_alerts" {
  source = "./aws/billing-alerts"
  # ...
}
```

### 3. IAM Permissions

The AWS credentials used must have these permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutMetricAlarm",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:DeleteAlarms",
        "sns:CreateTopic",
        "sns:Subscribe",
        "sns:GetTopicAttributes",
        "sns:SetTopicAttributes",
        "sns:DeleteTopic",
        "budgets:CreateBudget",
        "budgets:ModifyBudget",
        "budgets:DeleteBudget",
        "budgets:ViewBudget",
        "kms:CreateKey",
        "kms:CreateAlias",
        "kms:DescribeKey",
        "kms:EnableKeyRotation"
      ],
      "Resource": "*"
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alarm_name | Name of the CloudWatch billing alarm | `string` | `"billing-alert"` | no |
| monthly_threshold | Monthly cost threshold in dollars | `number` | `10.0` | no |
| warning_threshold | Warning threshold (lower than monthly_threshold). Set to 0 to disable | `number` | `5.0` | no |
| currency | Currency code for billing alerts | `string` | `"USD"` | no |
| email_address | Email address for alerts. Leave empty to skip | `string` | `""` | no |
| sms_number | SMS phone number (E.164 format). Leave empty to skip | `string` | `""` | no |
| https_endpoint | HTTPS webhook URL. Leave empty to skip | `string` | `""` | no |
| sns_topic_name | Name of the SNS topic | `string` | `"billing-alerts-topic"` | no |
| send_ok_notifications | Send notifications when alarm returns to OK | `bool` | `false` | no |
| enable_encryption | Enable KMS encryption for SNS | `bool` | `false` | no |
| create_budget | Create an AWS Budget | `bool` | `true` | no |
| budget_name | Name of the AWS Budget | `string` | `"monthly-cost-budget"` | no |
| service_thresholds | Map of service names to cost thresholds | `map(number)` | `{}` | no |
| tags | Additional tags for resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| sns_topic_arn | ARN of the SNS topic for billing alerts |
| sns_topic_name | Name of the SNS topic |
| billing_alarm_arn | ARN of the main billing CloudWatch alarm |
| billing_alarm_name | Name of the main billing alarm |
| warning_alarm_arn | ARN of the warning alarm (if created) |
| warning_alarm_name | Name of the warning alarm (if created) |
| service_alarm_arns | Map of service names to alarm ARNs |
| budget_id | ID of the AWS Budget (if created) |
| budget_name | Name of the AWS Budget (if created) |
| kms_key_id | ID of the KMS key (if encryption enabled) |
| kms_key_arn | ARN of the KMS key (if encryption enabled) |

## How It Works

### CloudWatch Billing Alarms

1. **Main Alarm**: Triggers when estimated charges exceed `monthly_threshold`
2. **Warning Alarm**: (Optional) Triggers at `warning_threshold` for early warning
3. **Service Alarms**: (Optional) Per-service cost monitoring
4. **Evaluation**: Checks every 6 hours using maximum estimated charges
5. **Notifications**: Sends alerts via SNS to configured endpoints

### AWS Budgets

If `create_budget = true`, creates a monthly budget with:
- **80% threshold**: Warning notification
- **90% forecasted**: Proactive alert if forecast exceeds budget
- **100% threshold**: Critical alert when budget is exceeded

### SNS Notifications

The module creates an SNS topic and subscribes your notification endpoints:
- **Email**: Requires email confirmation (check your inbox/spam)
- **SMS**: Immediate delivery (charges may apply for SMS)
- **HTTPS**: Webhook integration for Slack, PagerDuty, etc.

## Email Confirmation

After deployment, if you provided an email address:

1. Check your email inbox (and spam folder)
2. Look for "AWS Notification - Subscription Confirmation"
3. Click the confirmation link
4. You'll start receiving alerts once confirmed

## Per-Service Monitoring

Monitor specific AWS services individually:

```hcl
service_thresholds = {
  "Amazon Elastic Compute Cloud - Compute" = 5.0
  "Amazon Simple Storage Service"          = 2.0
  "Amazon Relational Database Service"     = 3.0
  "AWS Lambda"                             = 1.0
  "Amazon DynamoDB"                        = 1.0
}
```

Common service names:
- `Amazon Elastic Compute Cloud - Compute` - EC2
- `Amazon Simple Storage Service` - S3
- `Amazon Relational Database Service` - RDS
- `AWS Lambda` - Lambda
- `Amazon DynamoDB` - DynamoDB
- `Amazon CloudFront` - CloudFront
- `Amazon Route 53` - Route 53

## Testing

After deployment, test your alerts:

### 1. Check Resources

```bash
# Verify alarm exists
aws cloudwatch describe-alarms --alarm-names "billing-alert"

# Check SNS topic
aws sns list-topics | grep billing-alerts

# Verify budget
aws budgets describe-budgets --account-id YOUR_ACCOUNT_ID
```

### 2. Test SNS Subscription

```bash
# Manually publish test message
aws sns publish \
  --topic-arn "arn:aws:sns:us-east-1:ACCOUNT_ID:billing-alerts-topic" \
  --message "Test billing alert" \
  --subject "Test Alert"
```

### 3. Monitor in Console

- Go to CloudWatch → Alarms → billing-alert
- Go to AWS Budgets → View your budget
- Go to Cost Explorer → Analyze costs

## Cost Considerations

This module is **completely free** within AWS free tier:
- ✅ CloudWatch: 10 alarms (free tier)
- ✅ SNS: 1,000 email notifications/month (free tier)
- ✅ AWS Budgets: First 2 budgets free
- ⚠️ SMS: Not free ($0.50+ per message in US)
- ✅ KMS: 20,000 requests/month free tier

## Troubleshooting

### Alarm Not Triggering

**Issue**: Alarm doesn't trigger even when costs exceed threshold

**Solutions**:
1. Wait 6 hours (alarm evaluation period)
2. Verify billing alerts enabled in AWS console
3. Check CloudWatch metrics: `AWS/Billing` namespace should exist
4. Ensure using `us-east-1` region

### Email Not Received

**Issue**: Not receiving email notifications

**Solutions**:
1. Check spam/junk folder
2. Confirm SNS subscription (check email for confirmation link)
3. Verify email address is correct
4. Check SNS topic subscription in AWS console

### Budget Not Created

**Issue**: AWS Budget fails to create

**Solutions**:
1. Check IAM permissions for `budgets:*` actions
2. Verify account has access to AWS Budgets
3. Check if you have existing budgets (free tier = 2 budgets)

### Costs Still Increasing

**Issue**: Alerts triggered but costs continue to rise

**Actions**:
1. Immediately check AWS Cost Explorer
2. Identify expensive services
3. Stop/terminate resources exceeding free tier
4. Enable more granular service-specific alarms

## Best Practices

1. **Set Conservative Thresholds**: Set `monthly_threshold` well below your actual budget
2. **Use Warning Threshold**: Enable `warning_threshold` at 50% of main threshold
3. **Enable Multiple Channels**: Configure email AND webhook for redundancy
4. **Monitor Regularly**: Check AWS Cost Explorer weekly
5. **Service-Specific Alarms**: Use `service_thresholds` for critical services
6. **Test Notifications**: Send test alerts to verify configuration
7. **Document Thresholds**: Tag resources with cost expectations
8. **Review Monthly**: Adjust thresholds based on usage patterns

## Integration Examples

### Slack Webhook

```hcl
module "billing_alerts" {
  source = "./aws/billing-alerts"
  
  email_address  = "team@example.com"
  https_endpoint = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXX"
  monthly_threshold = 10.0
}
```

### PagerDuty Integration

Use PagerDuty's SNS integration endpoint as `https_endpoint`.

### Multiple Email Recipients

For multiple email addresses, manually subscribe them to the SNS topic:

```bash
aws sns subscribe \
  --topic-arn $(terraform output -raw sns_topic_arn) \
  --protocol email \
  --notification-endpoint another-email@example.com
```

## Related Modules

- [ec2-free-tier](../ec2-free-tier/) - EC2 instances within free tier
- [s3-free-tier](../s3-free-tier/) - S3 storage within free tier
- [lambda-free-tier](../lambda-free-tier/) - Lambda functions within free tier

## Further Reading

- [AWS Free Tier](https://aws.amazon.com/free/)
- [CloudWatch Billing Alarms](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/monitor_estimated_charges_with_cloudwatch.html)
- [AWS Budgets](https://aws.amazon.com/aws-cost-management/aws-budgets/)
- [SNS Email Notifications](https://docs.aws.amazon.com/sns/latest/dg/sns-email-notifications.html)

## Support

Found a bug or have a feature request? [Open an issue](https://github.com/lstasi/taf/issues)

---

**Remember**: Always deploy this module first! 🛡️
