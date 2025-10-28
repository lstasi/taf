# AWS SNS (Simple Notification Service) - Always Free Documentation

**Current Phase**: Documentation

This document describes AWS SNS and how to use it within the always-free tier limits.

## 🎯 Always Free Limits

AWS SNS is part of the AWS **always-free tier** (not limited to 12 months):

- **1,000 email deliveries** per month (perpetually free)
- **1 million mobile push notifications** per month (perpetually free)
- **100,000 HTTP/HTTPS deliveries** per month (perpetually free)
- **1,000 publishes** per month (perpetually free)
- **No time limit**: These limits never expire

### Understanding SNS Pricing

**Free Tier Breakdown**:
- **Email/Email-JSON**: 1,000 deliveries/month
- **Mobile Push (iOS, Android, etc.)**: 1 million notifications/month
- **HTTP/HTTPS endpoints**: 100,000 deliveries/month
- **SMS**: NOT free (costs per message, varies by country)
- **AWS Lambda**: 100,000 deliveries/month
- **SQS**: 100,000 deliveries/month

### Practical Examples

**Example 1: Billing Alerts**
- 30 billing notifications/month (daily checks)
- **Result**: Well within 1,000 email limit ✅

**Example 2: Application Monitoring**
- 100 error alerts/month
- 50 warning alerts/month
- **Result**: 150 emails well within limit ✅

**Example 3: Mobile App**
- 50,000 push notifications/month
- **Result**: Well within 1M push limit ✅

## ⚠️ What Causes Charges

You will incur charges if:
- ❌ Exceed 1,000 email deliveries/month
- ❌ Exceed 1M push notifications/month
- ❌ Exceed 100,000 HTTP/HTTPS deliveries/month
- ❌ Use SMS messages (NOT free, $0.50+ per message in US)
- ❌ Use FIFO topics (not in free tier)
- ❌ Data transfer out beyond AWS free tier (100GB/month aggregate)
- ❌ Use SNS API extensively beyond included requests

## 🏗️ Use Cases Within Free Tier

### Excellent Use Cases
- ✅ **Billing alerts**: CloudWatch billing alarms → SNS → Email
- ✅ **Error notifications**: Application errors → SNS → Email/Slack
- ✅ **System alerts**: CloudWatch alarms → SNS → Multiple channels
- ✅ **Mobile push**: App notifications (within 1M limit)
- ✅ **Webhooks**: SNS → HTTP/HTTPS endpoint (Slack, Discord, etc.)
- ✅ **Lambda triggers**: SNS → Lambda function
- ✅ **SQS fanout**: SNS → Multiple SQS queues
- ✅ **Audit logging**: Critical events → SNS → Multiple subscribers
- ✅ **CI/CD notifications**: Build/deploy status → SNS → Team
- ✅ **Health checks**: Monitoring alerts → SNS → On-call team

### Avoid For
- ❌ **SMS notifications**: Not free (use email instead)
- ❌ **High-frequency notifications**: >1,000 emails/month
- ❌ **Marketing campaigns**: Use Amazon SES instead
- ❌ **Large broadcasts**: Consider batching or alternative services

## 🎨 Architecture Patterns

### Pattern 1: CloudWatch Alarms → SNS → Email
```
CloudWatch Alarm
    ↓
SNS Topic (1k emails/month free)
    ↓
Email Subscription
```

**Use case**: Billing and monitoring alerts
**Cost**: Free within limits

### Pattern 2: Lambda → SNS → Multiple Subscribers
```
Lambda Function
    ↓
SNS Topic
    ↓
├─ Email (1k/month free)
├─ HTTP/HTTPS (100k/month free)
└─ Lambda (100k/month free)
```

**Use case**: Multi-channel notifications
**Cost**: Free within limits

### Pattern 3: SNS Fan-Out to SQS
```
API Gateway
    ↓
Lambda
    ↓
SNS Topic
    ↓
├─ SQS Queue 1 (processing)
├─ SQS Queue 2 (analytics)
└─ SQS Queue 3 (archival)
```

**Use case**: Distribute work to multiple queues
**Cost**: Free within limits

### Pattern 4: Mobile Push Notifications
```
Backend API
    ↓
SNS Topic
    ↓
└─ Mobile Push (1M/month free)
   ├─ iOS (APNs)
   ├─ Android (FCM)
   └─ Other platforms
```

**Use case**: Mobile app push notifications
**Cost**: Free within limits

## 📊 SNS Topics and Subscriptions

### Creating an SNS Topic

**Standard Topic (Free Tier)**:
```hcl
resource "aws_sns_topic" "alerts" {
  name              = "app-alerts"
  display_name      = "Application Alerts"
  
  # Optional: Enable encryption
  kms_master_key_id = "alias/aws/sns"  # AWS managed key (free)
  
  tags = {
    FreeTier    = "true"
    Environment = "production"
  }
}
```

**FIFO Topic (NOT Free Tier)**:
```hcl
# NOT recommended for free tier - FIFO topics are not included
resource "aws_sns_topic" "fifo" {
  name                        = "app-alerts.fifo"
  fifo_topic                  = true
  content_based_deduplication = true
  # FIFO topics incur charges
}
```

### SNS Subscriptions

**Email Subscription**:
```hcl
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "alerts@example.com"
  
  # Note: Email subscriptions require confirmation
}
```

**HTTP/HTTPS Webhook**:
```hcl
resource "aws_sns_topic_subscription" "webhook" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "https"
  endpoint  = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
}
```

**Lambda Subscription**:
```hcl
resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.processor.arn
}

resource "aws_lambda_permission" "sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alerts.arn
}
```

**SQS Subscription**:
```hcl
resource "aws_sns_topic_subscription" "sqs" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.processing.arn
}
```

**Mobile Push (iOS)**:
```hcl
resource "aws_sns_platform_application" "ios" {
  name     = "ios-app"
  platform = "APNS"  # Apple Push Notification Service
  
  platform_credential = var.apns_certificate  # From Apple Developer
}

resource "aws_sns_platform_endpoint" "ios_device" {
  platform_application_arn = aws_sns_platform_application.ios.arn
  token                    = var.device_token
}
```

## 🔧 Publishing to SNS

### From Lambda (Python)
```python
import boto3
import json

sns = boto3.client('sns')

def lambda_handler(event, context):
    topic_arn = 'arn:aws:sns:us-east-1:123456789012:app-alerts'
    
    # Simple message
    sns.publish(
        TopicArn=topic_arn,
        Subject='Application Alert',
        Message='An error occurred in the application'
    )
    
    # Structured message for multiple protocols
    message = {
        'default': 'Fallback message',
        'email': 'Detailed error information for email',
        'sqs': json.dumps({'event': 'error', 'details': {...}})
    }
    
    sns.publish(
        TopicArn=topic_arn,
        Subject='Alert',
        Message=json.dumps(message),
        MessageStructure='json'
    )
```

### From AWS CLI
```bash
# Simple publish
aws sns publish \
  --topic-arn "arn:aws:sns:us-east-1:123456789012:app-alerts" \
  --subject "Test Alert" \
  --message "This is a test notification"

# With message attributes
aws sns publish \
  --topic-arn "arn:aws:sns:us-east-1:123456789012:app-alerts" \
  --message "Alert message" \
  --message-attributes '{
    "severity": {"DataType": "String", "StringValue": "high"},
    "source": {"DataType": "String", "StringValue": "api"}
  }'
```

### From Terraform (Testing)
```bash
# After deployment, test with AWS CLI
terraform output -raw sns_topic_arn | xargs -I {} aws sns publish \
  --topic-arn {} \
  --subject "Test" \
  --message "Test message"
```

## 📈 Monitoring SNS Usage

### CloudWatch Metrics (Free)

SNS publishes metrics to CloudWatch automatically:
- **NumberOfMessagesPublished**: Total messages published
- **NumberOfNotificationsDelivered**: Successful deliveries
- **NumberOfNotificationsFailed**: Failed deliveries
- **NumberOfNotificationsFilteredOut-InvalidAttributes**: Filtered messages

### Monitoring Alarm
```hcl
resource "aws_cloudwatch_metric_alarm" "sns_failures" {
  alarm_name          = "sns-delivery-failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "NumberOfNotificationsFailed"
  namespace           = "AWS/SNS"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "Alert when SNS delivery failures occur"
  
  dimensions = {
    TopicName = aws_sns_topic.alerts.name
  }
  
  alarm_actions = [aws_sns_topic.critical_alerts.arn]
}
```

### Tracking Email Deliveries
```hcl
resource "aws_cloudwatch_metric_alarm" "sns_email_limit" {
  alarm_name          = "sns-email-limit-warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "NumberOfNotificationsDelivered"
  namespace           = "AWS/SNS"
  period              = "2592000"  # 30 days
  statistic           = "Sum"
  threshold           = "900"  # 90% of 1,000 free tier
  alarm_description   = "Approaching SNS email free tier limit"
  
  dimensions = {
    TopicName = aws_sns_topic.alerts.name
  }
}
```

## 🛡️ Staying Within Free Tier

### Email Notification Strategy
1. **Consolidate notifications**: Batch related alerts
2. **Use appropriate severity**: Only email critical issues
3. **Throttle frequency**: Limit notifications per time period
4. **Use HTTP webhooks**: 100k free vs 1k emails
5. **Fan-out to multiple channels**: Email for critical, HTTP for info
6. **Daily digests**: Combine multiple alerts into one email

### Best Practices
- **Set up billing alerts**: Monitor SNS usage costs
- **Use message filtering**: Reduce unnecessary deliveries
- **Implement retry logic**: For failed deliveries
- **Monitor delivery metrics**: Track success/failure rates
- **Tag topics**: For cost allocation and organization
- **Test subscriptions**: Verify delivery before production
- **Document escalation**: Clear process for critical alerts

## 🧪 Example Configurations

### Multi-Channel Alert System
```hcl
# SNS topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "multi-channel-alerts"
}

# Email for critical alerts
resource "aws_sns_topic_subscription" "critical_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "oncall@example.com"
  
  filter_policy = jsonencode({
    severity = ["critical"]
  })
}

# Slack webhook for all alerts
resource "aws_sns_topic_subscription" "slack" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "https"
  endpoint  = var.slack_webhook_url
}

# Lambda for processing
resource "aws_sns_topic_subscription" "processor" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.alert_processor.arn
}
```

### CloudWatch to SNS Integration
```hcl
resource "aws_sns_topic" "cloudwatch_alarms" {
  name = "cloudwatch-alarms"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.cloudwatch_alarms.arn
  protocol  = "email"
  endpoint  = "devops@example.com"
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  
  dimensions = {
    FunctionName = "my-function"
  }
}
```

## 🔒 Security Best Practices

### Topic Policies
```hcl
resource "aws_sns_topic_policy" "alerts_policy" {
  arn = aws_sns_topic.alerts.arn
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.alerts.arn
      }
    ]
  })
}
```

### Encryption
```hcl
resource "aws_sns_topic" "encrypted" {
  name = "encrypted-topic"
  
  kms_master_key_id = "alias/aws/sns"  # AWS managed key (free)
  # OR use custom KMS key (may incur costs)
  # kms_master_key_id = aws_kms_key.custom.id
}
```

### Subscription Confirmation
- Email subscriptions require confirmation
- Check spam folder for confirmation emails
- Use `PendingConfirmation` status to track
- Implement timeout for confirmations

## 🐛 Troubleshooting

### Issue: Email Not Received

**Symptoms**: Subscription created but no emails received

**Solutions**:
1. Check spam/junk folder
2. Confirm subscription (check email for confirmation link)
3. Verify email address is correct
4. Check topic policy allows publishing
5. Test with AWS CLI publish command
6. Review CloudWatch metrics for failures

### Issue: HTTP/HTTPS Delivery Failures

**Symptoms**: NumberOfNotificationsFailed metric increasing

**Solutions**:
1. Verify endpoint URL is correct and accessible
2. Check endpoint returns 200 status code
3. Implement proper SNS message verification
4. Review endpoint logs for errors
5. Test endpoint manually with sample SNS payload
6. Configure delivery policy for retries

### Issue: Exceeding Free Tier

**Symptoms**: Unexpected charges for SNS

**Solutions**:
1. Check CloudWatch metrics for message count
2. Identify topics with high volume
3. Implement message filtering
4. Consolidate notifications
5. Use HTTP instead of email where possible
6. Implement throttling in application

## 🔗 Related Resources

### AWS Documentation
- [SNS Free Tier](https://aws.amazon.com/sns/pricing/)
- [SNS Developer Guide](https://docs.aws.amazon.com/sns/latest/dg/)
- [SNS Message Filtering](https://docs.aws.amazon.com/sns/latest/dg/sns-message-filtering.html)
- [SNS Mobile Push](https://docs.aws.amazon.com/sns/latest/dg/sns-mobile-application-as-subscriber.html)

### TAF Modules
- [billing-alerts](../billing-alerts/) - Uses SNS for notifications
- [cloudwatch](../cloudwatch/) - SNS for alarm notifications
- [lambda](../lambda/) - SNS to Lambda integration

## 📝 Implementation Checklist

When implementing SNS:

- [ ] Deploy billing-alerts module first
- [ ] Create SNS topics with descriptive names
- [ ] Set up email subscriptions (confirm them!)
- [ ] Configure HTTP/HTTPS webhooks if needed
- [ ] Set up topic policies for security
- [ ] Enable encryption if needed
- [ ] Monitor delivery metrics in CloudWatch
- [ ] Set up alarms for failures
- [ ] Test all subscriptions
- [ ] Document notification procedures
- [ ] Tag topics for cost tracking
- [ ] Implement message filtering if needed

## 💡 Tips for Staying Free

1. **Email sparingly**: 1,000/month limit
2. **Use HTTP webhooks**: 100k limit vs 1k emails
3. **Avoid SMS**: Not free
4. **Filter messages**: Reduce unnecessary deliveries
5. **Batch notifications**: Combine related alerts
6. **Monitor usage**: Track delivery counts
7. **Use Lambda**: 100k deliveries/month free
8. **Fan-out pattern**: Single publish, multiple subscribers
9. **Daily digests**: Instead of real-time for non-critical
10. **Test conservatively**: Each test counts toward limit

## 📞 Support

- [TAF Issues](https://github.com/lstasi/taf/issues)
- [AWS Support](https://aws.amazon.com/support/)
- [SNS Forum](https://repost.aws/tags/TA5-tf6H8pR_qGZUhkS-sVhw/amazon-simple-notification-service)

---

**Remember**: Always deploy [billing-alerts](../billing-alerts/) first! 🛡️
