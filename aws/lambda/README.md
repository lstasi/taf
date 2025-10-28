# AWS Lambda (Always Free) Documentation

**Current Phase**: Documentation

This document describes the AWS Lambda service and how to use it within the always-free tier limits.

## 🎯 Always Free Limits

AWS Lambda is part of the AWS **always-free tier** (not limited to 12 months):

- **1 Million requests** per month (perpetually free)
- **400,000 GB-seconds** of compute time per month (perpetually free)
- **Includes**: All Lambda functions in your account
- **No time limit**: These limits never expire

### What are GB-seconds?

GB-seconds is a measure of Lambda execution time multiplied by memory allocation:
- **1 GB-second** = 1 function running for 1 second with 1GB memory
- **400,000 GB-seconds** examples:
  - 400,000 executions × 1 second × 1GB memory
  - 800,000 executions × 0.5 seconds × 1GB memory
  - 3,200,000 executions × 0.125 seconds × 1GB memory

### Practical Examples

**Example 1: Simple API (128MB)**
- Memory: 128MB (0.125GB)
- Duration: 100ms (0.1 seconds)
- Monthly invocations: 1M requests (free tier limit)
- GB-seconds used: 1M × 0.1 × 0.125 = 12,500 GB-seconds
- **Result**: Well within free tier ✅

**Example 2: Data Processing (512MB)**
- Memory: 512MB (0.5GB)
- Duration: 500ms (0.5 seconds)
- Monthly invocations: 100,000
- GB-seconds used: 100K × 0.5 × 0.5 = 25,000 GB-seconds
- **Result**: Well within free tier ✅

**Example 3: Heavy Processing (1.5GB)**
- Memory: 1536MB (1.5GB)
- Duration: 1 second
- Monthly invocations: 200,000
- GB-seconds used: 200K × 1 × 1.5 = 300,000 GB-seconds
- **Result**: Within free tier ✅

## ⚠️ What Causes Charges

You will incur charges if:
- ❌ Exceed 1M requests/month
- ❌ Exceed 400,000 GB-seconds/month
- ❌ Use Provisioned Concurrency (not free)
- ❌ Data transfer out exceeds 100GB/month
- ❌ Use Lambda@Edge (different pricing)
- ❌ Use VPC data processing (small charges may apply)
- ❌ Store large function code in Lambda (use S3 for packages >50MB)

## 🏗️ Use Cases Within Free Tier

### Excellent Use Cases
- ✅ **API backends**: REST APIs with API Gateway
- ✅ **Scheduled tasks**: Cron jobs via EventBridge
- ✅ **Webhooks**: GitHub, Stripe, Slack integrations
- ✅ **Data transformations**: ETL pipelines with DynamoDB
- ✅ **Image processing**: Thumbnail generation (optimize memory)
- ✅ **Chatbots**: Slack, Discord, Telegram bots
- ✅ **Automation**: CloudWatch Events triggers
- ✅ **Serverless backends**: CRUD operations
- ✅ **IoT processing**: Device data processing

### Consider Alternatives For
- ⚠️ **Long-running jobs**: >15 minute execution (Lambda max timeout)
- ⚠️ **High-frequency polling**: Consider EventBridge or SQS
- ⚠️ **Large data transfers**: Watch bandwidth limits
- ⚠️ **Stateful applications**: Use with DynamoDB for state
- ⚠️ **Very high traffic**: Monitor request counts closely

## 🎨 Architecture Patterns

### Pattern 1: API Gateway + Lambda + DynamoDB
```
API Gateway (Free tier: 1M requests/month)
    ↓
Lambda (Free tier: 1M requests/month)
    ↓
DynamoDB (Free tier: 25GB, 25 WCU/RCU)
```

**Use case**: REST API for web/mobile app
**Cost**: Free within limits

### Pattern 2: EventBridge + Lambda
```
EventBridge Schedule (Free tier: 1M invocations)
    ↓
Lambda (processes scheduled task)
    ↓
SNS (sends notification)
```

**Use case**: Daily backup, report generation
**Cost**: Free within limits

### Pattern 3: S3 + Lambda + DynamoDB
```
S3 Event (requires S3 - 12-month free tier)
    ↓
Lambda (processes uploaded file)
    ↓
DynamoDB (stores metadata)
```

**Use case**: File upload processing
**Cost**: S3 only free for 12 months ⚠️

### Pattern 4: SQS + Lambda + SNS
```
SQS (1M requests/month free)
    ↓
Lambda (processes messages)
    ↓
SNS (sends alerts)
```

**Use case**: Async job processing
**Cost**: Free within limits

## 📊 Memory and Duration Optimization

### Memory Configuration

Lambda charges are based on allocated memory (not used memory):

| Memory | Price per GB-sec | When to Use |
|--------|------------------|-------------|
| **128MB** | Cheapest | Simple APIs, webhooks |
| **256MB** | Low cost | Data processing, JSON parsing |
| **512MB** | Moderate | Image processing, API calls |
| **1024MB** | Balanced | Database queries, computations |
| **1536MB+** | Higher cost | CPU-intensive, large data |

**Tip**: Higher memory = more CPU power. Sometimes functions run faster with more memory, using fewer GB-seconds overall.

### Duration Optimization Tips

1. **Cold starts**: First invocation is slower (warm up period)
   - Keep functions small and focused
   - Use provisioned concurrency (costs extra)
   - Accept 1-3 second cold start delay

2. **Code optimization**:
   - Minimize dependencies
   - Use connection pooling for databases
   - Cache static data in `/tmp` directory
   - Lazy load modules when possible

3. **Timeout settings**:
   - Set realistic timeouts (default: 3 seconds, max: 15 minutes)
   - Don't set unnecessarily high timeouts
   - Monitor actual execution times

## 🔧 Configuration Best Practices

### Environment Variables
```hcl
environment_variables = {
  LOG_LEVEL      = "INFO"
  DYNAMODB_TABLE = "my-table"
  API_KEY        = "stored-in-secrets-manager"  # Reference, don't hardcode
}
```

### IAM Permissions (Least Privilege)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:Query"
      ],
      "Resource": "arn:aws:dynamodb:*:*:table/specific-table"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
```

### Reserved Concurrency

**Do NOT use** reserved concurrency in free tier:
- Reserved concurrency costs extra
- Free tier = unreserved concurrency only
- Throttling happens at 1,000 concurrent executions (default)

### Monitoring Strategy

Use CloudWatch (free tier: 10 metrics, 10 alarms):

1. **Invocations**: Track request count
2. **Duration**: Monitor execution time
3. **Errors**: Alert on high error rates
4. **Throttles**: Detect concurrency limits
5. **Cost**: Set billing alarms (see billing-alerts module)

## 📈 Free Tier Monitoring

### Calculate Your Usage

**Monthly GB-seconds formula**:
```
Total GB-seconds = Σ (invocations × duration_seconds × memory_GB)
```

**Example calculation**:
- API endpoint: 500K invocations/month × 0.2s × 0.256GB = 25,600 GB-seconds
- Scheduled job: 1K invocations/month × 5s × 1GB = 5,000 GB-seconds
- Webhook: 10K invocations/month × 0.1s × 0.128GB = 128 GB-seconds
- **Total**: 30,728 GB-seconds (7.7% of free tier) ✅

### CloudWatch Metrics to Monitor

```hcl
# Example alarm for Lambda invocations
resource "aws_cloudwatch_metric_alarm" "lambda_invocations" {
  alarm_name          = "lambda-high-invocations"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Invocations"
  namespace           = "AWS/Lambda"
  period              = "2592000"  # 30 days
  statistic           = "Sum"
  threshold           = "900000"   # 90% of 1M
  alarm_description   = "Alert when Lambda invocations exceed 90% of free tier"
  
  dimensions = {
    FunctionName = "my-function"
  }
}
```

### Tracking GB-seconds

CloudWatch doesn't directly expose GB-seconds, but you can calculate:

```
GB-seconds = (Duration × MemorySize) / 1024
```

Create a custom CloudWatch metric or use AWS Cost Explorer.

## 🛡️ Staying Within Free Tier

### Strategies

1. **Set conservative limits**:
   - Configure max concurrent executions (if needed)
   - Set appropriate timeouts
   - Monitor usage weekly

2. **Use efficient patterns**:
   - Batch operations when possible
   - Cache frequently used data
   - Minimize cold starts

3. **Optimize memory**:
   - Start with 256MB
   - Test and adjust based on actual needs
   - Don't over-provision

4. **Rate limiting**:
   - Implement API rate limiting
   - Use API Gateway throttling
   - Queue requests with SQS

5. **Monitoring**:
   - Set alarms at 80% of free tier limits
   - Review CloudWatch metrics weekly
   - Use billing alerts (see billing-alerts module)

## 🧪 Example Configurations

### Minimal Lambda Function
```hcl
resource "aws_lambda_function" "minimal" {
  filename      = "function.zip"
  function_name = "minimal-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  
  memory_size = 128
  timeout     = 3
  
  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }
  
  tags = {
    FreeTier = "true"
    Purpose  = "api-backend"
  }
}
```

### Lambda with DynamoDB
```hcl
resource "aws_lambda_function" "dynamodb_function" {
  filename      = "function.zip"
  function_name = "dynamodb-processor"
  role          = aws_iam_role.lambda_dynamodb_role.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  
  memory_size = 256
  timeout     = 10
  
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.my_table.name
    }
  }
}

resource "aws_iam_role_policy" "lambda_dynamodb" {
  role = aws_iam_role.lambda_dynamodb_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query"
        ]
        Resource = aws_dynamodb_table.my_table.arn
      }
    ]
  })
}
```

### Scheduled Lambda (EventBridge)
```hcl
resource "aws_lambda_function" "scheduled" {
  filename      = "function.zip"
  function_name = "scheduled-task"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  
  memory_size = 512
  timeout     = 30
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "daily-task"
  description         = "Trigger Lambda daily"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "lambda"
  arn       = aws_lambda_function.scheduled.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scheduled.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}
```

## 🔒 Security Best Practices

1. **Never hardcode secrets**:
   - Use AWS Secrets Manager or Parameter Store
   - Use environment variables for non-sensitive config
   - Rotate credentials regularly

2. **Least privilege IAM**:
   - Grant only necessary permissions
   - Use specific resource ARNs
   - Avoid wildcards in policies

3. **VPC considerations**:
   - VPC adds cold start latency
   - May incur data processing charges
   - Only use if needed for security/compliance

4. **Encryption**:
   - Environment variables encrypted at rest (default)
   - Use KMS for sensitive data
   - Enable encryption in transit

5. **Logging**:
   - Don't log sensitive data
   - Use structured logging
   - Set appropriate log retention (watch free tier: 5GB)

## 🐛 Troubleshooting

### Issue: Exceeding Free Tier Requests

**Symptoms**: Billing alarm triggered, unexpected charges

**Solutions**:
1. Check CloudWatch metrics for invocation count
2. Identify which function has high traffic
3. Implement API throttling with API Gateway
4. Add rate limiting in application code
5. Use SQS to queue requests

### Issue: High GB-seconds Usage

**Symptoms**: Charges despite low request count

**Solutions**:
1. Review function memory allocation
2. Optimize execution time
3. Profile code for bottlenecks
4. Reduce function timeout if too high
5. Consider caching to reduce execution time

### Issue: Cold Start Performance

**Symptoms**: First request is slow

**Solutions**:
1. Keep deployment package small
2. Minimize dependencies
3. Use runtime-specific optimizations
4. Accept cold starts or use Provisioned Concurrency (costs extra)
5. Implement warming strategy if needed

### Issue: Throttling Errors

**Symptoms**: "Rate exceeded" errors

**Solutions**:
1. Check concurrent execution limit
2. Implement exponential backoff
3. Use SQS to buffer requests
4. Request limit increase from AWS (if justified)

## 🔗 Related Resources

### AWS Documentation
- [Lambda Free Tier](https://aws.amazon.com/lambda/pricing/)
- [Lambda Developer Guide](https://docs.aws.amazon.com/lambda/latest/dg/)
- [Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)
- [Lambda Limits](https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html)

### TAF Modules
- [billing-alerts](../billing-alerts/) - Monitor Lambda costs
- [dynamodb](../dynamodb/) - Database for Lambda functions
- [sns](../sns/) - Notifications from Lambda
- [sqs](../sqs/) - Queue requests to Lambda
- [cloudwatch](../cloudwatch/) - Monitor Lambda metrics

### Tools
- [Serverless Framework](https://www.serverless.com/)
- [AWS SAM](https://aws.amazon.com/serverless/sam/)
- [Lambda Power Tuning](https://github.com/alexcasalboni/aws-lambda-power-tuning)

## 📝 Implementation Checklist

When implementing Lambda functions:

- [ ] Deploy billing-alerts module first
- [ ] Set memory to minimum needed (start with 256MB)
- [ ] Set realistic timeout (not max)
- [ ] Implement proper error handling
- [ ] Use least-privilege IAM roles
- [ ] Enable CloudWatch Logs
- [ ] Set up CloudWatch alarms for invocations
- [ ] Calculate expected GB-seconds usage
- [ ] Test thoroughly in sandbox
- [ ] Monitor usage for first week
- [ ] Optimize based on actual metrics
- [ ] Document function purpose and limits
- [ ] Tag resources for cost tracking

## 💡 Tips for Staying Free

1. **Be efficient**: Optimize code to reduce duration
2. **Right-size memory**: Don't over-allocate
3. **Monitor actively**: Check metrics weekly
4. **Use batching**: Process multiple items per invocation
5. **Cache wisely**: Use `/tmp` for static data (512MB limit)
6. **Set alarms**: At 80% of free tier limits
7. **Document usage**: Track GB-seconds per function
8. **Review monthly**: Adjust based on patterns

## 📞 Support

- [TAF Issues](https://github.com/lstasi/taf/issues)
- [AWS Support](https://aws.amazon.com/support/)
- [AWS Lambda Forum](https://repost.aws/tags/TA4IvCeWI1TE2WX16-bP3bfg/aws-lambda)

---

**Remember**: Always deploy [billing-alerts](../billing-alerts/) first! 🛡️
