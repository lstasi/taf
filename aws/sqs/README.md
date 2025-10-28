# AWS SQS (Simple Queue Service) - Always Free Documentation

**Current Phase**: Documentation

This document describes AWS SQS and how to use it within the always-free tier limits.

## 🎯 Always Free Limits

AWS SQS is part of the AWS **always-free tier** (not limited to 12 months):

- **1 million requests** per month (perpetually free)
- **Includes**: Standard and FIFO queues
- **Request types**: SendMessage, ReceiveMessage, DeleteMessage, ChangeMessageVisibility
- **No time limit**: These limits never expire

### Understanding SQS Requests

**What counts as a request**:
- **SendMessage**: Publishing a message to queue
- **ReceiveMessage**: Polling for messages (even if empty)
- **DeleteMessage**: Removing a message after processing
- **ChangeMessageVisibility**: Extending processing time
- **Batch operations**: Count as one request per message (up to 10 messages)

**Request calculation example**:
```
API call with 5 messages in batch = 5 requests
API call with empty poll = 1 request
```

### Practical Examples

**Example 1: Low-Traffic Queue**
- 10,000 messages published/month
- 10,000 receive requests
- 10,000 delete requests
- **Total**: 30,000 requests (3% of free tier) ✅

**Example 2: High-Frequency Polling**
- Poll every 10 seconds (8,640 polls/day)
- 259,200 empty polls/month
- 20,000 actual messages processed
- 20,000 deletes
- **Total**: 299,200 requests (30% of free tier) ✅

**Example 3: Batch Processing**
- 100,000 messages sent in batches of 10 = 10,000 requests
- 100,000 messages received in batches = 10,000 requests
- 100,000 deletes in batches = 10,000 requests
- **Total**: 30,000 requests (3% of free tier) ✅

## ⚠️ What Causes Charges

You will incur charges if:
- ❌ Exceed 1 million requests/month
- ❌ Data transfer out beyond AWS free tier (100GB/month aggregate)
- ❌ Use SQS Extended Client Library with S3 (S3 costs may apply)
- ❌ Use long polling excessively (each poll is a request)
- ❌ Implement very short polling intervals

## 🏗️ Use Cases Within Free Tier

### Excellent Use Cases
- ✅ **Asynchronous processing**: Decouple services
- ✅ **Job queues**: Background task processing
- ✅ **Load leveling**: Handle traffic spikes
- ✅ **Microservices communication**: Service-to-service messaging
- ✅ **Event buffering**: Store events for processing
- ✅ **Dead letter queues**: Handle failed messages
- ✅ **Priority queues**: Multiple queues for priorities
- ✅ **Fan-out pattern**: SNS → Multiple SQS queues
- ✅ **Batch operations**: Process in groups
- ✅ **Lambda triggers**: Asynchronous function invocation

### Consider Alternatives For
- ⚠️ **Real-time processing**: Use Lambda with API Gateway instead
- ⚠️ **Very high throughput**: >1M requests/month sustained
- ⚠️ **Message ordering critical**: Use FIFO carefully (same costs)
- ⚠️ **Large messages**: Use S3 + SQS Extended Client (S3 costs)

## 🎨 Architecture Patterns

### Pattern 1: Lambda → SQS → Lambda
```
API Gateway
    ↓
Lambda (Publisher)
    ↓
SQS Queue (1M requests/month free)
    ↓
Lambda (Consumer)
```

**Use case**: Asynchronous task processing
**Cost**: Free within limits

### Pattern 2: SNS Fan-Out to Multiple SQS
```
SNS Topic
    ↓
├─ SQS Queue 1 (Processing)
├─ SQS Queue 2 (Analytics)
└─ SQS Queue 3 (Logging)
```

**Use case**: Multiple consumers for same event
**Cost**: Free within limits

### Pattern 3: SQS with Dead Letter Queue
```
Main Queue (SQS)
    ↓
Lambda Processor
    ↓
(On failure) → Dead Letter Queue (SQS)
                    ↓
                Alert via SNS
```

**Use case**: Handle failed message processing
**Cost**: Free within limits

### Pattern 4: Priority Queue Pattern
```
Application
    ↓
├─ High Priority Queue (SQS)
├─ Medium Priority Queue (SQS)
└─ Low Priority Queue (SQS)
    ↓
Lambda Processors (Different configs)
```

**Use case**: Process messages by priority
**Cost**: Free within limits

## 📊 Queue Types

### Standard Queue (Default)

**Characteristics**:
- **At-least-once delivery**: Messages may be delivered multiple times
- **Best-effort ordering**: Messages generally delivered in order
- **Unlimited throughput**: Near-unlimited messages per second
- **Free tier eligible**: Yes

**Use when**:
- Order doesn't matter
- Duplicate messages are acceptable
- High throughput needed

### FIFO Queue

**Characteristics**:
- **Exactly-once processing**: No duplicates
- **Strict ordering**: Messages delivered in exact order
- **Limited throughput**: 300 messages/second (3,000 with batching)
- **Free tier eligible**: Yes (same 1M request limit)

**Use when**:
- Order is critical
- Duplicates must be prevented
- Throughput <300 msg/sec

**Note**: FIFO queue names must end with `.fifo`

## 🔧 Queue Configuration

### Standard Queue Example
```hcl
resource "aws_sqs_queue" "standard" {
  name                       = "task-queue"
  visibility_timeout_seconds = 300  # 5 minutes
  message_retention_seconds  = 345600  # 4 days
  max_message_size          = 262144  # 256 KB
  delay_seconds             = 0
  receive_wait_time_seconds = 10  # Long polling (recommended)
  
  # Dead letter queue
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })
  
  tags = {
    FreeTier = "true"
  }
}

# Dead letter queue
resource "aws_sqs_queue" "dlq" {
  name = "task-queue-dlq"
  message_retention_seconds = 1209600  # 14 days
}
```

### FIFO Queue Example
```hcl
resource "aws_sqs_queue" "fifo" {
  name                        = "orders.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  visibility_timeout_seconds  = 300
  message_retention_seconds   = 345600
  
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.fifo_dlq.arn
    maxReceiveCount     = 3
  })
  
  tags = {
    FreeTier = "true"
  }
}

resource "aws_sqs_queue" "fifo_dlq" {
  name       = "orders-dlq.fifo"
  fifo_queue = true
}
```

### Key Configuration Parameters

| Parameter | Standard Queue | FIFO Queue | Recommendation |
|-----------|---------------|------------|----------------|
| **visibility_timeout_seconds** | 30-43200 | 30-43200 | Set to max processing time + buffer |
| **message_retention_seconds** | 60-1209600 | 60-1209600 | 4 days (345600) typical |
| **max_message_size** | 1024-262144 | 1024-262144 | 256 KB (default) |
| **delay_seconds** | 0-900 | 0-900 | Use per-message delay instead |
| **receive_wait_time_seconds** | 0-20 | 0-20 | 10-20 (long polling) |

## 📝 Sending and Receiving Messages

### Sending Messages (Python)
```python
import boto3
import json

sqs = boto3.client('sqs')
queue_url = 'https://sqs.us-east-1.amazonaws.com/123456789012/task-queue'

# Send single message
response = sqs.send_message(
    QueueUrl=queue_url,
    MessageBody=json.dumps({
        'task': 'process-order',
        'order_id': '12345'
    }),
    MessageAttributes={
        'Priority': {
            'StringValue': 'High',
            'DataType': 'String'
        }
    }
)

# Send batch (more efficient)
messages = [
    {
        'Id': str(i),
        'MessageBody': json.dumps({'task': f'task-{i}'})
    }
    for i in range(10)  # Max 10 per batch
]

response = sqs.send_message_batch(
    QueueUrl=queue_url,
    Entries=messages
)
```

### Receiving Messages (Python)
```python
# Receive with long polling (recommended)
response = sqs.receive_message(
    QueueUrl=queue_url,
    MaxNumberOfMessages=10,  # Max 10
    WaitTimeSeconds=20,  # Long polling
    MessageAttributeNames=['All'],
    VisibilityTimeout=300  # 5 minutes to process
)

messages = response.get('Messages', [])

for message in messages:
    # Process message
    body = json.loads(message['Body'])
    print(f"Processing: {body}")
    
    # Delete after successful processing
    sqs.delete_message(
        QueueUrl=queue_url,
        ReceiptHandle=message['ReceiptHandle']
    )
```

### Lambda Integration
```hcl
# Lambda function to process SQS messages
resource "aws_lambda_function" "sqs_processor" {
  filename      = "processor.zip"
  function_name = "sqs-processor"
  role          = aws_iam_role.lambda_sqs.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  
  memory_size = 256
  timeout     = 60
}

# Event source mapping
resource "aws_lambda_event_source_mapping" "sqs_lambda" {
  event_source_arn = aws_sqs_queue.standard.arn
  function_name    = aws_lambda_function.sqs_processor.arn
  batch_size       = 10
  enabled          = true
  
  # Partial batch response
  function_response_types = ["ReportBatchItemFailures"]
}

# IAM permissions
resource "aws_iam_role_policy" "lambda_sqs" {
  role = aws_iam_role.lambda_sqs.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.standard.arn
      }
    ]
  })
}
```

## 📈 Monitoring and Optimization

### CloudWatch Metrics (Free)

SQS publishes metrics to CloudWatch:
- **ApproximateNumberOfMessagesVisible**: Messages available
- **ApproximateNumberOfMessagesNotVisible**: Messages in-flight
- **ApproximateNumberOfMessagesDelayed**: Messages delayed
- **NumberOfMessagesSent**: Messages published
- **NumberOfMessagesReceived**: Receive requests
- **NumberOfMessagesDeleted**: Messages processed
- **ApproximateAgeOfOldestMessage**: Oldest message age

### Monitoring Alarms
```hcl
# Alert on queue depth
resource "aws_cloudwatch_metric_alarm" "queue_depth" {
  alarm_name          = "sqs-queue-depth-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "300"
  statistic           = "Average"
  threshold           = "1000"
  alarm_description   = "Queue depth is high"
  
  dimensions = {
    QueueName = aws_sqs_queue.standard.name
  }
  
  alarm_actions = [var.sns_topic_arn]
}

# Alert on old messages
resource "aws_cloudwatch_metric_alarm" "message_age" {
  alarm_name          = "sqs-message-age-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "3600"  # 1 hour
  alarm_description   = "Messages not being processed"
  
  dimensions = {
    QueueName = aws_sqs_queue.standard.name
  }
  
  alarm_actions = [var.sns_topic_arn]
}
```

## 🛡️ Staying Within Free Tier

### Request Optimization

1. **Use batching**: Send/receive/delete up to 10 messages per request
2. **Long polling**: Use `WaitTimeSeconds=20` to reduce empty polls
3. **Appropriate visibility timeout**: Avoid unnecessary ChangeMessageVisibility
4. **Delete after processing**: Don't let messages return to queue
5. **Monitor request count**: Track via CloudWatch

### Cost Calculation
```
Total Requests = Send + Receive + Delete + Other
Goal: Stay under 1M requests/month

Example:
- 50,000 messages sent (using batch of 10) = 5,000 requests
- 50,000 messages received (batch of 10) = 5,000 requests  
- 50,000 messages deleted (batch of 10) = 5,000 requests
- 100,000 empty polls (long polling 20s) = 100,000 requests
Total = 115,000 requests (11.5% of free tier) ✅
```

### Best Practices

1. **Enable long polling**: Reduces empty receive requests
2. **Use batch operations**: Up to 10 messages per API call
3. **Set appropriate timeouts**: Match processing time
4. **Implement exponential backoff**: For retries
5. **Monitor dead letter queue**: Catch failed messages
6. **Use visibility timeout wisely**: Extend only when needed
7. **Delete processed messages**: Don't leave in queue
8. **Calculate request costs**: Before deployment

## 🐛 Troubleshooting

### Issue: Exceeding Free Tier

**Symptoms**: Unexpected charges

**Solutions**:
1. Check CloudWatch metrics for request count
2. Identify polling frequency (reduce if too high)
3. Implement batching for all operations
4. Use long polling to reduce empty receives
5. Review application logic for unnecessary requests

### Issue: Messages Not Processing

**Symptoms**: Queue depth increasing

**Solutions**:
1. Check Lambda function errors (if using Lambda)
2. Verify consumer is running
3. Check visibility timeout is appropriate
4. Review dead letter queue for failed messages
5. Scale consumers if throughput insufficient

### Issue: Duplicate Messages (Standard Queue)

**Symptoms**: Same message processed multiple times

**Solutions**:
1. Implement idempotency in consumer
2. Use FIFO queue if duplicates not acceptable
3. Store message IDs to detect duplicates
4. Delete messages immediately after processing
5. Use appropriate visibility timeout

### Issue: Message Loss

**Symptoms**: Messages disappearing

**Solutions**:
1. Check message retention period
2. Verify messages being deleted intentionally
3. Review dead letter queue configuration
4. Check for purge operations
5. Verify consumer error handling

## 🔗 Related Resources

### AWS Documentation
- [SQS Free Tier](https://aws.amazon.com/sqs/pricing/)
- [SQS Developer Guide](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/)
- [SQS Best Practices](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-best-practices.html)
- [Standard vs FIFO Queues](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-queue-types.html)

### TAF Modules
- [billing-alerts](../billing-alerts/) - Monitor SQS costs
- [lambda](../lambda/) - SQS to Lambda integration
- [sns](../sns/) - SNS to SQS fan-out

## 📝 Implementation Checklist

When implementing SQS:

- [ ] Deploy billing-alerts module first
- [ ] Choose appropriate queue type (Standard vs FIFO)
- [ ] Configure visibility timeout for processing time
- [ ] Set up dead letter queue
- [ ] Enable long polling (WaitTimeSeconds=10-20)
- [ ] Implement batch operations
- [ ] Set up CloudWatch alarms
- [ ] Configure IAM permissions (least privilege)
- [ ] Implement idempotent consumers
- [ ] Test error handling
- [ ] Monitor request count
- [ ] Tag queues for cost tracking
- [ ] Document queue purpose and limits

## 💡 Tips for Staying Free

1. **Always use batching**: 10 messages per request
2. **Enable long polling**: Reduces empty receives
3. **Minimize polling frequency**: Balance latency vs cost
4. **Delete promptly**: After successful processing
5. **Use visibility timeout wisely**: Don't extend unnecessarily
6. **Monitor requests**: Track via CloudWatch
7. **Calculate before deploying**: Estimate monthly requests
8. **Use Lambda triggers**: More efficient than polling
9. **Implement exponential backoff**: For retries
10. **Consider event-driven**: SNS + SQS vs polling

## 📞 Support

- [TAF Issues](https://github.com/lstasi/taf/issues)
- [AWS Support](https://aws.amazon.com/support/)
- [SQS Forum](https://repost.aws/tags/TA78iVOM8uShempRkT-yIOLw/amazon-simple-queue-service)

---

**Remember**: Always deploy [billing-alerts](../billing-alerts/) first! 🛡️
