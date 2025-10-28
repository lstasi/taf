# AWS CloudWatch (Always Free) Documentation

**Current Phase**: Documentation

This document describes AWS CloudWatch and how to use it within the always-free tier limits for monitoring your AWS resources.

## 🎯 Always Free Limits

AWS CloudWatch is part of the AWS **always-free tier** (not limited to 12 months):

- **10 custom metrics** (perpetually free)
- **10 alarms** on metrics (perpetually free)
- **1 million API requests** per month (perpetually free)
- **5 GB log data ingestion** per month (perpetually free)
- **5 GB log data archive** (perpetually free)
- **3 dashboards** with up to 50 metrics each per month (perpetually free)
- **No time limit**: These limits never expire

### What's Included

**Metrics**:
- AWS service metrics (EC2, Lambda, DynamoDB) are FREE and don't count toward 10 custom metrics
- Custom metrics you publish count toward the 10 custom metric limit
- High-resolution metrics (1-second) cost extra

**Alarms**:
- Standard alarms (1-minute or 5-minute periods) are free
- High-resolution alarms (10-second or 30-second periods) cost extra
- Composite alarms cost extra

**Logs**:
- 5GB ingestion covers most small to medium applications
- Archive storage beyond ingestion is not free after first 5GB

## ⚠️ What Causes Charges

You will incur charges if:
- ❌ Exceed 10 custom metrics
- ❌ Exceed 10 alarms
- ❌ Exceed 5GB log ingestion per month
- ❌ Store logs beyond 5GB archive
- ❌ Use high-resolution metrics (1-second granularity)
- ❌ Use high-resolution alarms
- ❌ Use composite alarms
- ❌ Create more than 3 dashboards
- ❌ Use GetMetricData API extensively (beyond 1M requests)
- ❌ Use CloudWatch Insights queries (charged separately)
- ❌ Use CloudWatch Contributor Insights
- ❌ Use CloudWatch Anomaly Detection

## 🏗️ Use Cases Within Free Tier

### Excellent Use Cases
- ✅ **Billing monitoring**: Track AWS costs (see billing-alerts module)
- ✅ **Lambda monitoring**: Invocations, errors, duration
- ✅ **DynamoDB monitoring**: RCU/WCU consumption, throttling
- ✅ **Application logs**: Centralized logging (within 5GB limit)
- ✅ **API Gateway monitoring**: Request counts, latency, errors
- ✅ **System health**: CPU, memory, disk metrics (custom metrics)
- ✅ **Auto-scaling triggers**: Based on metric thresholds
- ✅ **Simple dashboards**: Up to 3 dashboards
- ✅ **Error alerting**: Email notifications via SNS

### Consider Alternatives For
- ⚠️ **High-frequency metrics**: >10 custom metrics needed
- ⚠️ **Large log volumes**: >5GB/month (consider sampling)
- ⚠️ **Long-term log storage**: Consider S3 for archival
- ⚠️ **Complex queries**: CloudWatch Insights costs extra
- ⚠️ **Real-time monitoring**: High-resolution metrics cost extra

## 🎨 Architecture Patterns

### Pattern 1: Lambda + CloudWatch Logs + Alarms
```
Lambda Function
    ↓
CloudWatch Logs (5GB/month free)
    ↓
CloudWatch Alarm (10 alarms free)
    ↓
SNS Notification (1k emails/month free)
```

**Use case**: Monitor Lambda errors and latency
**Cost**: Free within limits

### Pattern 2: Custom Metrics + Dashboard
```
Application
    ↓
CloudWatch Custom Metrics (10 metrics free)
    ↓
CloudWatch Dashboard (3 dashboards free)
    ↓
CloudWatch Alarms (10 alarms free)
```

**Use case**: Application performance monitoring
**Cost**: Free within limits

### Pattern 3: DynamoDB + CloudWatch + Auto Scaling
```
DynamoDB Table
    ↓
CloudWatch Metrics (AWS metrics free)
    ↓
CloudWatch Alarms
    ↓
Auto Scaling Policy
```

**Use case**: Auto-scale DynamoDB based on usage
**Cost**: Free within limits

## 📊 Monitoring Strategy

### AWS Service Metrics (Always Free)

These AWS service metrics are **completely free** and don't count toward custom metric limits:
- **Lambda**: Invocations, Duration, Errors, Throttles, ConcurrentExecutions
- **DynamoDB**: ConsumedReadCapacityUnits, ConsumedWriteCapacityUnits, UserErrors
- **SNS**: NumberOfMessagesPublished, NumberOfNotificationsFailed
- **SQS**: NumberOfMessagesSent, NumberOfMessagesReceived, ApproximateNumberOfMessagesVisible
- **API Gateway**: Count, Latency, 4XXError, 5XXError

### Custom Metrics (10 Free)

Use your 10 custom metrics wisely:
1. **Application errors**: Track application-specific errors
2. **Business metrics**: Orders placed, signups, etc.
3. **Cache hit rate**: Application cache performance
4. **Queue depth**: Custom queue sizes
5. **Response times**: Application-specific latencies
6. **Active users**: Concurrent user count
7. **Data processing**: Records processed
8. **API rate limits**: Track API usage
9. **Resource utilization**: Custom resource tracking
10. **Health checks**: Application health status

### Publishing Custom Metrics

**From Lambda**:
```python
import boto3
cloudwatch = boto3.client('cloudwatch')

cloudwatch.put_metric_data(
    Namespace='MyApp',
    MetricData=[
        {
            'MetricName': 'OrdersProcessed',
            'Value': 1.0,
            'Unit': 'Count',
            'Dimensions': [
                {'Name': 'Environment', 'Value': 'Production'}
            ]
        }
    ]
)
```

**From AWS CLI**:
```bash
aws cloudwatch put-metric-data \
  --namespace "MyApp" \
  --metric-name "CustomMetric" \
  --value 42.0 \
  --unit Count
```

## 🔧 CloudWatch Alarms Configuration

### Basic Alarm Example
```hcl
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "lambda-high-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"  # 5 minutes
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "Alert when Lambda errors exceed threshold"
  treat_missing_data  = "notBreaching"
  
  alarm_actions = [aws_sns_topic.alerts.arn]
  
  dimensions = {
    FunctionName = "my-function"
  }
  
  tags = {
    FreeTier = "true"
  }
}
```

### Alarm Best Practices

1. **Use appropriate periods**: 1-minute (free) or 5-minute (free)
2. **Set evaluation periods**: Reduce false positives with multiple evaluations
3. **Choose correct statistic**: Sum, Average, Maximum, Minimum, SampleCount
4. **Handle missing data**: Set `treat_missing_data` appropriately
5. **Tag alarms**: For cost tracking and organization

### Alarm States
- **OK**: Metric is within threshold
- **ALARM**: Metric breached threshold
- **INSUFFICIENT_DATA**: Not enough data to evaluate

## 📝 CloudWatch Logs

### Log Groups and Streams

**Log Group**: Container for log streams (e.g., /aws/lambda/my-function)
**Log Stream**: Sequence of log events (e.g., 2024/01/01/[$LATEST]abc123)

### Lambda Logging Example
```python
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info('Processing event', extra={'event_id': event.get('id')})
    try:
        # Process event
        logger.info('Event processed successfully')
    except Exception as e:
        logger.error('Error processing event', exc_info=True)
    return {'statusCode': 200}
```

### Log Retention

Set appropriate retention to manage costs:
```hcl
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/my-function"
  retention_in_days = 7  # 1, 3, 5, 7, 14, 30, 60, 90, 120, etc.
  
  tags = {
    FreeTier = "true"
  }
}
```

**Retention recommendations**:
- **Development**: 1-7 days
- **Production**: 7-30 days
- **Compliance**: 30-90+ days (may exceed free tier)

### Managing Log Volume

**Stay within 5GB/month**:
1. **Filter logs**: Only log important events
2. **Use appropriate log levels**: INFO, WARN, ERROR (not DEBUG in production)
3. **Sampling**: Log subset of requests for high-traffic apps
4. **Structured logging**: More efficient than free text
5. **Retention policies**: Delete old logs

## 🎯 CloudWatch Dashboards

### Dashboard Limits
- **3 dashboards** free per month
- **Up to 50 metrics** per dashboard
- Additional dashboards: $3/month each

### Example Dashboard
```hcl
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "app-monitoring"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", { stat = "Sum" }],
            [".", "Errors", { stat = "Sum" }],
            [".", "Duration", { stat = "Average" }]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Lambda Metrics"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/DynamoDB", "ConsumedReadCapacityUnits", { stat = "Sum" }],
            [".", "ConsumedWriteCapacityUnits", { stat = "Sum" }]
          ]
          period = 300
          region = "us-east-1"
          title  = "DynamoDB Capacity"
        }
      }
    ]
  })
}
```

### Dashboard Best Practices
1. **Combine related metrics**: Group by service or function
2. **Use appropriate time ranges**: Last hour, day, week
3. **Set auto-refresh**: 1 minute, 5 minutes, etc.
4. **Share dashboards**: Make critical metrics visible to team
5. **Monitor the monitors**: Track alarm states

## 🛡️ Staying Within Free Tier

### Custom Metrics Strategy
- Prioritize the 10 most critical metrics
- Combine related metrics when possible
- Use AWS service metrics (free) instead of custom when available
- Aggregate data before publishing metrics

### Log Management Strategy
- Set short retention periods (7-14 days)
- Filter logs in application code
- Use sampling for high-volume logging
- Monitor ingestion with CloudWatch metric
- Archive to S3 if long-term storage needed

### Alarm Strategy
- Use 10 alarms for critical issues only
- Combine related conditions when possible
- Use SNS topics for multiple notification channels
- Test alarms to avoid false positives
- Document alarm thresholds

## 🧪 Example Configurations

### Lambda Monitoring Setup
```hcl
# Log group for Lambda
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 7
}

# Alarm for Lambda errors
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.function_name}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_actions       = [var.sns_topic_arn]
  
  dimensions = {
    FunctionName = var.function_name
  }
}

# Alarm for Lambda throttles
resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  alarm_name          = "${var.function_name}-throttles"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_actions       = [var.sns_topic_arn]
  
  dimensions = {
    FunctionName = var.function_name
  }
}
```

### DynamoDB Monitoring Setup
```hcl
# Alarm for DynamoDB read capacity
resource "aws_cloudwatch_metric_alarm" "dynamodb_read_capacity" {
  alarm_name          = "${var.table_name}-read-capacity"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ConsumedReadCapacityUnits"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "600"  # 20 RCU * 300 seconds * 80% = alarm at 80% capacity
  alarm_actions       = [var.sns_topic_arn]
  
  dimensions = {
    TableName = var.table_name
  }
}

# Alarm for DynamoDB throttling
resource "aws_cloudwatch_metric_alarm" "dynamodb_throttles" {
  alarm_name          = "${var.table_name}-throttles"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "UserErrors"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_actions       = [var.sns_topic_arn]
  
  dimensions = {
    TableName = var.table_name
  }
}
```

## 🐛 Troubleshooting

### Issue: Exceeding Custom Metric Limit

**Symptoms**: Unable to publish more than 10 custom metrics

**Solutions**:
1. Audit existing custom metrics
2. Remove unused metrics
3. Combine related metrics with dimensions
4. Use AWS service metrics instead
5. Consider aggregating metrics before publishing

### Issue: Log Ingestion Exceeding 5GB

**Symptoms**: Unexpected charges for log ingestion

**Solutions**:
1. Check CloudWatch Logs Insights for top log producers
2. Reduce log level (INFO instead of DEBUG)
3. Implement log sampling
4. Set shorter retention periods
5. Filter logs in application code

### Issue: Alarm Not Triggering

**Symptoms**: Alarm doesn't fire when expected

**Solutions**:
1. Check alarm state in CloudWatch console
2. Verify metric is publishing data
3. Review alarm configuration (threshold, period, statistic)
4. Check `treat_missing_data` setting
5. Verify SNS topic subscription is confirmed

## 🔗 Related Resources

### AWS Documentation
- [CloudWatch Free Tier](https://aws.amazon.com/cloudwatch/pricing/)
- [CloudWatch User Guide](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/)
- [CloudWatch Logs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/)
- [CloudWatch Alarms](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html)

### TAF Modules
- [billing-alerts](../billing-alerts/) - Uses CloudWatch for billing monitoring
- [lambda](../lambda/) - Lambda metrics in CloudWatch
- [dynamodb](../dynamodb/) - DynamoDB metrics in CloudWatch
- [sns](../sns/) - SNS for alarm notifications

## 📝 Implementation Checklist

When implementing CloudWatch monitoring:

- [ ] Deploy billing-alerts module first
- [ ] Create log groups with appropriate retention
- [ ] Set up critical alarms (max 10)
- [ ] Configure SNS topics for notifications
- [ ] Create dashboards (max 3)
- [ ] Monitor log ingestion volume
- [ ] Use AWS service metrics (free) when possible
- [ ] Limit custom metrics to 10 most important
- [ ] Test alarms to verify they trigger correctly
- [ ] Document alarm thresholds and escalation
- [ ] Tag all CloudWatch resources
- [ ] Review metrics weekly

## 💡 Tips for Staying Free

1. **Prioritize AWS service metrics**: They're free and comprehensive
2. **Use 10 custom metrics wisely**: Most critical business/app metrics
3. **Set appropriate log retention**: 7-14 days for most use cases
4. **Filter aggressively**: Only log what you need
5. **Use log sampling**: For high-traffic applications
6. **Leverage dimensions**: Maximize metric utility
7. **Monitor your monitoring**: Track log volume and metric count
8. **Consolidate alarms**: Combine related conditions
9. **Use dashboards efficiently**: Max 3 dashboards with 50 metrics each
10. **Archive to S3**: For long-term log storage needs

## 📞 Support

- [TAF Issues](https://github.com/lstasi/taf/issues)
- [AWS Support](https://aws.amazon.com/support/)
- [CloudWatch Forum](https://repost.aws/tags/TA4X2RjCjtQEOm9NrJ3ywjcA/amazon-cloud-watch)

---

**Remember**: Always deploy [billing-alerts](../billing-alerts/) first! 🛡️
