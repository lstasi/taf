# AWS Step Functions (Always Free) Documentation

**Current Phase**: Implementation ✅

This document describes AWS Step Functions and how to use it within the always-free tier limits.

## 🎯 Always Free Limits

AWS Step Functions is part of the AWS **always-free tier** (not limited to 12 months):

- **4,000 state transitions** per month (perpetually free)
- **Includes**: Standard workflows only
- **No time limit**: These limits never expire

### Understanding State Transitions

**What is a state transition?**
- Each step in your workflow that processes data
- Transitions between states (Pass, Task, Choice, etc.)
- Both successful and failed transitions count

**Example workflow (6 transitions)**:
```
Start → ValidateInput → ProcessData → Choice → SaveResult → End
```

### Practical Examples

**Example 1: Simple Workflow (5 transitions)**
- Start → Lambda → DynamoDB → SNS → End
- 500 executions/month
- **Total**: 2,500 transitions (62.5% of free tier) ✅

**Example 2: Complex Workflow (20 transitions)**
- Multiple Lambda calls, choices, parallel branches
- 150 executions/month
- **Total**: 3,000 transitions (75% of free tier) ✅

**Example 3: Daily Batch Job (10 transitions)**
- Runs daily (30 times/month)
- **Total**: 300 transitions (7.5% of free tier) ✅

## ⚠️ What Causes Charges

You will incur charges if:
- ❌ Exceed 4,000 state transitions/month
- ❌ Use Express Workflows (NOT free tier, charged per execution)
- ❌ Use Step Functions beyond free tier limits
- ❌ Data transfer out beyond AWS limits
- ❌ Use excessive Lambda, DynamoDB, SNS calls (separate charges)

### Express vs Standard Workflows

| Feature | Standard (Free Tier) | Express (NOT Free) |
|---------|---------------------|-------------------|
| **Free Tier** | ✅ 4,000 transitions/month | ❌ No free tier |
| **Duration** | Up to 1 year | Up to 5 minutes |
| **Execution rate** | 2,000/second | 100,000/second |
| **Pricing** | Per state transition | Per execution |
| **Use case** | Long-running, orchestration | High-throughput, short |

**Recommendation**: Use **Standard Workflows** for free tier

## 🏗️ Use Cases Within Free Tier

### Excellent Use Cases
- ✅ **ETL pipelines**: Extract → Transform → Load workflows
- ✅ **Order processing**: Validate → Process → Notify → Complete
- ✅ **Batch jobs**: Daily/weekly processing workflows
- ✅ **Approval workflows**: Request → Approve → Execute → Notify
- ✅ **Data processing**: Multiple Lambda functions orchestration
- ✅ **Microservices orchestration**: Coordinate service calls
- ✅ **Error handling**: Retry logic with exponential backoff
- ✅ **Scheduled tasks**: Complex multi-step cron jobs
- ✅ **Human tasks**: Wait for manual approval
- ✅ **Parallel processing**: Process multiple items concurrently

### Consider Alternatives For
- ⚠️ **High-frequency workflows**: >4,000 transitions/month
- ⚠️ **Very short workflows**: <5 seconds (use Lambda directly)
- ⚠️ **Real-time processing**: Express workflows (not free)
- ⚠️ **Simple tasks**: Single Lambda might suffice

## 🎨 Architecture Patterns

### Pattern 1: ETL Pipeline
```
Start
  ↓
Extract (Lambda) → Read from DynamoDB
  ↓
Transform (Lambda) → Process data
  ↓
Load (Lambda) → Write to DynamoDB
  ↓
Notify (SNS) → Send success notification
  ↓
End
```

**State transitions**: 5
**Use case**: Daily data processing
**Cost**: Free within limits

### Pattern 2: Order Processing
```
Start
  ↓
Validate Order (Lambda)
  ↓
Choice: Valid?
  ├─ Yes → Process Payment (Lambda)
  │         ↓
  │       Update Inventory (DynamoDB)
  │         ↓
  │       Send Confirmation (SNS)
  │         ↓
  │       End
  └─ No → Send Error (SNS)
            ↓
          End
```

**State transitions**: 6-7 (depending on path)
**Use case**: E-commerce order flow
**Cost**: Free within limits

### Pattern 3: Parallel Processing
```
Start
  ↓
Map State (Parallel)
  ├─ Process Item 1 (Lambda)
  ├─ Process Item 2 (Lambda)
  ├─ Process Item 3 (Lambda)
  └─ Process Item N (Lambda)
  ↓
Aggregate Results (Lambda)
  ↓
End
```

**State transitions**: 2 + N (items)
**Use case**: Batch processing multiple items
**Cost**: Free within limits

### Pattern 4: Error Handling with Retry
```
Start
  ↓
Try: Call External API (Lambda)
  ↓
Catch: On Error
  ├─ Retry (3 attempts with backoff)
  └─ Fallback → Send Alert (SNS)
  ↓
End
```

**State transitions**: 2-5 (depending on retries)
**Use case**: Resilient external service calls
**Cost**: Free within limits

## 📝 State Types

### Task State
Performs work via Lambda, ECS, SNS, SQS, DynamoDB, etc.
```json
{
  "ValidateInput": {
    "Type": "Task",
    "Resource": "arn:aws:lambda:us-east-1:123456789012:function:validate",
    "Next": "ProcessData"
  }
}
```

### Pass State
Passes input to output (useful for testing or transformation)
```json
{
  "AddMetadata": {
    "Type": "Pass",
    "Result": {
      "processed": true,
      "timestamp": "2024-01-01T00:00:00Z"
    },
    "ResultPath": "$.metadata",
    "Next": "NextState"
  }
}
```

### Choice State
Branching logic based on input
```json
{
  "ValidateAge": {
    "Type": "Choice",
    "Choices": [
      {
        "Variable": "$.age",
        "NumericGreaterThanEquals": 18,
        "Next": "ProcessAdult"
      },
      {
        "Variable": "$.age",
        "NumericLessThan": 18,
        "Next": "ProcessMinor"
      }
    ],
    "Default": "InvalidInput"
  }
}
```

### Wait State
Delay execution for specified time
```json
{
  "WaitForApproval": {
    "Type": "Wait",
    "Seconds": 3600,
    "Next": "CheckApproval"
  }
}
```

### Parallel State
Execute branches concurrently
```json
{
  "ProcessInParallel": {
    "Type": "Parallel",
    "Branches": [
      {
        "StartAt": "Branch1",
        "States": { ... }
      },
      {
        "StartAt": "Branch2",
        "States": { ... }
      }
    ],
    "Next": "Aggregate"
  }
}
```

### Map State
Iterate over array items
```json
{
  "ProcessItems": {
    "Type": "Map",
    "ItemsPath": "$.items",
    "Iterator": {
      "StartAt": "ProcessItem",
      "States": {
        "ProcessItem": {
          "Type": "Task",
          "Resource": "arn:aws:lambda:...",
          "End": true
        }
      }
    },
    "Next": "Complete"
  }
}
```

### Succeed/Fail States
Terminal states
```json
{
  "Success": {
    "Type": "Succeed"
  },
  "Failure": {
    "Type": "Fail",
    "Error": "ValidationError",
    "Cause": "Invalid input data"
  }
}
```

## 🔧 Example Configurations

### Simple Lambda Orchestration
```hcl
resource "aws_sfn_state_machine" "simple_workflow" {
  name     = "simple-workflow"
  role_arn = aws_iam_role.step_functions.arn
  
  definition = jsonencode({
    Comment = "Simple Lambda orchestration"
    StartAt = "ValidateInput"
    States = {
      ValidateInput = {
        Type     = "Task"
        Resource = aws_lambda_function.validate.arn
        Next     = "ProcessData"
      }
      ProcessData = {
        Type     = "Task"
        Resource = aws_lambda_function.process.arn
        Next     = "SaveResult"
      }
      SaveResult = {
        Type     = "Task"
        Resource = aws_lambda_function.save.arn
        End      = true
      }
    }
  })
  
  tags = {
    FreeTier = "true"
  }
}
```

### Workflow with Error Handling
```hcl
resource "aws_sfn_state_machine" "error_handling" {
  name     = "error-handling-workflow"
  role_arn = aws_iam_role.step_functions.arn
  
  definition = jsonencode({
    Comment = "Workflow with error handling"
    StartAt = "CallAPI"
    States = {
      CallAPI = {
        Type     = "Task"
        Resource = aws_lambda_function.api_call.arn
        Retry = [
          {
            ErrorEquals     = ["States.TaskFailed"]
            IntervalSeconds = 2
            MaxAttempts     = 3
            BackoffRate     = 2.0
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "HandleError"
          }
        ]
        Next = "Success"
      }
      HandleError = {
        Type     = "Task"
        Resource = aws_sns_topic.errors.arn
        End      = true
      }
      Success = {
        Type = "Succeed"
      }
    }
  })
}
```

### Parallel Processing Workflow
```hcl
resource "aws_sfn_state_machine" "parallel_processing" {
  name     = "parallel-processing"
  role_arn = aws_iam_role.step_functions.arn
  
  definition = jsonencode({
    Comment = "Process items in parallel"
    StartAt = "ProcessInParallel"
    States = {
      ProcessInParallel = {
        Type = "Parallel"
        Branches = [
          {
            StartAt = "ProcessA"
            States = {
              ProcessA = {
                Type     = "Task"
                Resource = aws_lambda_function.process_a.arn
                End      = true
              }
            }
          },
          {
            StartAt = "ProcessB"
            States = {
              ProcessB = {
                Type     = "Task"
                Resource = aws_lambda_function.process_b.arn
                End      = true
              }
            }
          }
        ]
        Next = "Aggregate"
      }
      Aggregate = {
        Type     = "Task"
        Resource = aws_lambda_function.aggregate.arn
        End      = true
      }
    }
  })
}
```

### IAM Role for Step Functions
```hcl
resource "aws_iam_role" "step_functions" {
  name = "step-functions-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "step_functions_policy" {
  role = aws_iam_role.step_functions.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = "arn:aws:lambda:*:*:function:*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = "arn:aws:sns:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/*"
      }
    ]
  })
}
```

## 📈 Monitoring and Optimization

### CloudWatch Metrics (Free)

Step Functions publishes metrics to CloudWatch:
- **ExecutionsStarted**: Number of executions started
- **ExecutionsSucceeded**: Successful executions
- **ExecutionsFailed**: Failed executions
- **ExecutionsTimedOut**: Timed out executions
- **ExecutionTime**: Duration of executions

### Monitoring Alarms
```hcl
resource "aws_cloudwatch_metric_alarm" "step_functions_failures" {
  alarm_name          = "step-functions-failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ExecutionsFailed"
  namespace           = "AWS/States"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "Step Functions failures detected"
  
  dimensions = {
    StateMachineArn = aws_sfn_state_machine.simple_workflow.arn
  }
  
  alarm_actions = [var.sns_topic_arn]
}

# Monitor state transitions
resource "aws_cloudwatch_metric_alarm" "state_transitions" {
  alarm_name          = "step-functions-transition-limit"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "StateTransition"
  namespace           = "AWS/States"
  period              = "2592000"  # 30 days
  statistic           = "Sum"
  threshold           = "3600"  # 90% of 4,000
  alarm_description   = "Approaching state transition limit"
  
  dimensions = {
    StateMachineArn = aws_sfn_state_machine.simple_workflow.arn
  }
  
  alarm_actions = [var.sns_topic_arn]
}
```

## 🛡️ Staying Within Free Tier

### Transition Optimization

1. **Minimize states**: Combine simple operations
2. **Use Pass states wisely**: They count as transitions
3. **Optimize Choice states**: Fewer branches = fewer transitions
4. **Batch operations**: Process multiple items in one Lambda call
5. **Monitor monthly transitions**: Track via CloudWatch

### Workflow Design Best Practices

1. **Keep workflows simple**: Fewer states = fewer transitions
2. **Use Lambda for complex logic**: Instead of multiple states
3. **Implement efficient error handling**: Don't retry unnecessarily
4. **Use EventBridge for scheduling**: Instead of continuous execution
5. **Calculate transitions before deploying**: Plan capacity

### Cost Calculation
```
Transitions per execution = Number of states in workflow
Monthly transitions = Executions per month × Transitions per execution
Goal: Stay under 4,000 transitions/month

Example:
- Workflow with 8 states
- 400 executions/month
- Total transitions = 400 × 8 = 3,200 (80% of free tier) ✅
```

## 🐛 Troubleshooting

### Issue: Exceeding Free Tier

**Symptoms**: Unexpected charges for state transitions

**Solutions**:
1. Check CloudWatch metrics for StateTransition count
2. Review workflow definitions for unnecessary states
3. Combine simple Pass states
4. Reduce execution frequency
5. Optimize workflow design

### Issue: Executions Timing Out

**Symptoms**: ExecutionsTimedOut metric increasing

**Solutions**:
1. Check individual state timeouts
2. Review Lambda function execution times
3. Increase workflow timeout if needed
4. Implement proper error handling
5. Monitor execution history for bottlenecks

### Issue: Failed Executions

**Symptoms**: ExecutionsFailed metric increasing

**Solutions**:
1. Review execution history in console
2. Check Lambda function errors
3. Verify IAM permissions
4. Implement retry logic
5. Add error catching states

## 🔗 Related Resources

### AWS Documentation
- [Step Functions Free Tier](https://aws.amazon.com/step-functions/pricing/)
- [Step Functions Developer Guide](https://docs.aws.amazon.com/step-functions/latest/dg/)
- [Amazon States Language](https://states-language.net/spec.html)
- [Step Functions Best Practices](https://docs.aws.amazon.com/step-functions/latest/dg/bp-express.html)

### TAF Modules
- [billing-alerts](../billing-alerts/) - Monitor Step Functions costs
- [lambda](../lambda/) - Lambda functions for Step Functions
- [dynamodb](../dynamodb/) - Data persistence
- [sns](../sns/) - Notifications from workflows

### Tools
- [Step Functions Local](https://docs.aws.amazon.com/step-functions/latest/dg/sfn-local.html)
- [AWS Toolkit for VS Code](https://aws.amazon.com/visualstudiocode/)

## 📝 Implementation Checklist

When implementing Step Functions:

- [ ] Deploy billing-alerts module first
- [ ] Use Standard Workflows (not Express)
- [ ] Design workflow with minimal states
- [ ] Implement error handling and retries
- [ ] Configure appropriate timeouts
- [ ] Set up CloudWatch alarms
- [ ] Configure IAM roles (least privilege)
- [ ] Test workflow with sample data
- [ ] Monitor state transition count
- [ ] Document workflow purpose and logic
- [ ] Tag state machines
- [ ] Calculate expected monthly transitions

## 💡 Tips for Staying Free

1. **Use Standard Workflows**: Express workflows have no free tier
2. **Minimize states**: Each state = 1 transition
3. **Batch processing**: Process multiple items per Lambda
4. **Efficient error handling**: Don't retry excessively
5. **Monitor transitions**: Track monthly usage
6. **Calculate before deploy**: Plan workflow capacity
7. **Use Lambda for logic**: Instead of multiple states
8. **Schedule wisely**: Don't run more frequently than needed
9. **Combine simple operations**: In single Lambda function
10. **Review regularly**: Optimize workflow designs

## 📞 Support

- [TAF Issues](https://github.com/lstasi/taf/issues)
- [AWS Support](https://aws.amazon.com/support/)
- [Step Functions Forum](https://repost.aws/tags/TAgOOj7k4qS0y0Rge5-iIF7Q/aws-step-functions)

---

**Remember**: Always deploy [billing-alerts](../billing-alerts/) first! 🛡️
