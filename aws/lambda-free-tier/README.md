# AWS Lambda Free Tier Module

Terraform module for deploying Lambda functions within AWS free tier limits.

## AWS Free Tier Limits (Always Free!)

- **1 million requests** per month (always free)
- **400,000 GB-seconds** of compute time per month (always free)
- **Example**: 128 MB function running for 3 seconds = 0.375 GB-seconds per invocation

## Features

- ✅ Supports all Lambda runtimes
- ✅ Automatic IAM role creation
- ✅ CloudWatch logging with configurable retention
- ✅ Error and throttle alarms
- ✅ Invocation monitoring
- ✅ Lambda function URLs
- ✅ VPC support (with cost warning)
- ✅ X-Ray tracing
- ✅ Dead letter queue support

## Usage

### Basic Example (Python)

First, create your function code:

```python
# lambda_function.py
def handler(event, context):
    return {
        'statusCode': 200,
        'body': 'Hello from Lambda!'
    }
```

Package it:
```bash
zip function.zip lambda_function.py
```

Deploy with Terraform:
```hcl
module "hello_lambda" {
  source = "./aws/lambda-free-tier"
  
  function_name = "hello-world"
  filename      = "function.zip"
  handler       = "lambda_function.handler"
  runtime       = "python3.11"
  
  alarm_actions = [module.billing_alerts.sns_topic_arn]
}
```

### Node.js Example

```javascript
// index.js
exports.handler = async (event) => {
    return {
        statusCode: 200,
        body: JSON.stringify('Hello from Node.js!')
    };
};
```

```hcl
module "node_lambda" {
  source = "./aws/lambda-free-tier"
  
  function_name = "node-function"
  filename      = "function.zip"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 10
  memory_size   = 256
}
```

### Lambda with Function URL (HTTP Endpoint)

```hcl
module "api_lambda" {
  source = "./aws/lambda-free-tier"
  
  function_name = "api-function"
  filename      = "api.zip"
  handler       = "index.handler"
  runtime       = "python3.11"
  
  # Enable public HTTP endpoint
  enable_function_url   = true
  function_url_auth_type = "NONE"  # Public access
  
  # CORS configuration
  function_url_cors = {
    allow_credentials = false
    allow_headers     = ["content-type", "x-api-key"]
    allow_methods     = ["GET", "POST"]
    allow_origins     = ["*"]
    expose_headers    = ["x-request-id"]
    max_age           = 3600
  }
  
  tags = {
    Purpose = "API"
  }
}

# Output the function URL
output "api_url" {
  value = module.api_lambda.function_url
}
```

### Advanced Example with S3 Trigger

```hcl
# Lambda function to process S3 uploads
module "s3_processor" {
  source = "./aws/lambda-free-tier"
  
  function_name = "s3-processor"
  filename      = "processor.zip"
  handler       = "index.handler"
  runtime       = "python3.11"
  timeout       = 30
  memory_size   = 512
  
  # Environment variables
  environment_variables = {
    BUCKET_NAME = module.my_bucket.bucket_id
    REGION      = "us-east-1"
  }
  
  # Additional IAM policies for S3 access
  additional_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]
  
  # Monitoring
  enable_error_alarm      = true
  enable_throttle_alarm   = true
  enable_invocation_alarm = true
  alarm_actions           = [module.billing_alerts.sns_topic_arn]
  
  # Logging
  log_retention_days = 7
  
  tags = {
    Environment = "production"
    Purpose     = "s3-processing"
  }
}

# Give S3 permission to invoke Lambda
resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = module.s3_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = module.my_bucket.bucket_arn
}

# Configure S3 to trigger Lambda
resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = module.my_bucket.bucket_id

  lambda_function {
    lambda_function_arn = module.s3_processor.function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "uploads/"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| function_name | Lambda function name | `string` | n/a | yes |
| filename | Path to deployment package (zip) | `string` | `""` | no |
| s3_bucket | S3 bucket with deployment package | `string` | `""` | no |
| s3_key | S3 key of deployment package | `string` | `""` | no |
| s3_object_version | S3 object version | `string` | `""` | no |
| handler | Function entrypoint | `string` | `"index.handler"` | no |
| runtime | Lambda runtime | `string` | `"python3.11"` | no |
| timeout | Timeout in seconds (1-900) | `number` | `3` | no |
| memory_size | Memory in MB (128-10240) | `number` | `128` | no |
| reserved_concurrent_executions | Reserved concurrency | `number` | `-1` | no |
| environment_variables | Environment variables | `map(string)` | `{}` | no |
| vpc_config | VPC configuration | `object` | `null` | no |
| dead_letter_target_arn | Dead letter queue ARN | `string` | `""` | no |
| enable_xray_tracing | Enable X-Ray | `bool` | `false` | no |
| enable_function_url | Enable function URL | `bool` | `false` | no |
| function_url_auth_type | Auth type (NONE or AWS_IAM) | `string` | `"AWS_IAM"` | no |
| function_url_cors | CORS configuration | `object` | `null` | no |
| log_retention_days | Log retention days | `number` | `7` | no |
| log_kms_key_id | KMS key for logs | `string` | `""` | no |
| additional_policy_arns | Additional IAM policies | `list(string)` | `[]` | no |
| enable_error_alarm | Enable error alarm | `bool` | `true` | no |
| error_threshold | Error count threshold | `number` | `5` | no |
| enable_throttle_alarm | Enable throttle alarm | `bool` | `true` | no |
| enable_invocation_alarm | Enable invocation alarm | `bool` | `true` | no |
| daily_invocation_threshold | Daily invocation threshold | `number` | `25000` | no |
| alarm_actions | SNS topic ARNs for alarms | `list(string)` | `[]` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| function_name | Function name |
| function_arn | Function ARN |
| function_qualified_arn | Qualified ARN |
| function_invoke_arn | Invoke ARN |
| function_url | Function URL (if enabled) |
| function_version | Latest version |
| role_arn | IAM role ARN |
| role_name | IAM role name |
| log_group_name | CloudWatch log group name |
| log_group_arn | CloudWatch log group ARN |
| free_tier_info | Free tier limits info |

## Important Notes

### Understanding GB-Seconds

**GB-seconds** = (Memory in GB) × (Duration in seconds)

Examples with 128 MB (0.125 GB):
- 1 second execution = 0.125 GB-seconds
- Free tier allows 400,000 GB-seconds/month
- At 128 MB: **3.2 million seconds** or **~888 hours** of execution

### Memory and Cost

Higher memory = more CPU power but uses more GB-seconds:
- **128 MB**: Cheapest, slowest
- **256 MB**: 2x cost but often faster
- **512 MB**: 4x cost but much faster
- **1024 MB**: 8x cost but very fast

**Tip**: Sometimes higher memory is cheaper because it runs faster!

### Cost Warnings

Additional charges for:
- ❌ **VPC functions**: NAT Gateway costs money ($0.045/hour + data charges)
- ❌ **Data transfer**: Between regions or to internet
- ❌ **Reserved concurrency**: Uses account-level concurrent execution quota
- ❌ **X-Ray tracing**: First 100k traces free, then $5/million

### Runtime Support

Supported runtimes (as of 2024):
- **Python**: 3.9, 3.10, 3.11, 3.12
- **Node.js**: 18.x, 20.x
- **Java**: 11, 17, 21
- **.NET**: 6, 8
- **Go**: 1.x
- **Ruby**: 3.2, 3.3

### Deployment Package

Create deployment package:

**Python**:
```bash
zip function.zip lambda_function.py
# With dependencies:
pip install -r requirements.txt -t .
zip -r function.zip .
```

**Node.js**:
```bash
zip function.zip index.js
# With dependencies:
npm install
zip -r function.zip .
```

**Go**:
```bash
GOOS=linux GOARCH=amd64 go build -o bootstrap main.go
zip function.zip bootstrap
```

### Testing Locally

Test Lambda functions locally with AWS SAM:

```bash
sam local invoke -e event.json
```

Or with Docker:
```bash
docker run -p 9000:8080 \
  -e AWS_ACCESS_KEY_ID=your-key \
  -e AWS_SECRET_ACCESS_KEY=your-secret \
  public.ecr.aws/lambda/python:3.11 \
  lambda_function.handler
```

## Monitoring

The module provides three CloudWatch alarms:

1. **Error Alarm**: Triggers when function has errors
2. **Throttle Alarm**: Triggers when invocations are throttled
3. **Invocation Alarm**: Monitors daily invocations vs. free tier limit

View logs:
```bash
aws logs tail /aws/lambda/function-name --follow
```

## Security Best Practices

1. **Least Privilege IAM**: Only grant necessary permissions
2. **Environment Variables**: Use for configuration, not secrets
3. **Secrets Manager**: Store sensitive data in AWS Secrets Manager
4. **Function URLs**: Use AWS_IAM auth unless public endpoint needed
5. **VPC**: Only use VPC if accessing private resources (costs money)
6. **Encryption**: Enable KMS encryption for sensitive logs

## Examples

### Invoke Function

```bash
# AWS CLI
aws lambda invoke \
  --function-name function-name \
  --payload '{"key":"value"}' \
  response.json

# With Function URL
curl -X POST https://xxxxx.lambda-url.us-east-1.on.aws/ \
  -H "Content-Type: application/json" \
  -d '{"key":"value"}'
```

### Update Function Code

```bash
# Create new package
zip function.zip lambda_function.py

# Update
aws lambda update-function-code \
  --function-name function-name \
  --zip-file fileb://function.zip
```

## Troubleshooting

### Function Timing Out

1. Increase `timeout` (max 900 seconds)
2. Optimize code performance
3. Increase `memory_size` for more CPU

### Out of Memory

1. Increase `memory_size`
2. Optimize memory usage in code
3. Process data in batches

### Throttling

1. Check concurrent executions in CloudWatch
2. Increase account-level concurrency limit
3. Use `reserved_concurrent_executions` to limit specific functions

### High Costs

1. Check invocation count and duration in CloudWatch
2. Optimize function code to run faster
3. Reduce unnecessary invocations
4. Consider batching operations

## Related Modules

- [billing-alerts](../billing-alerts/) - Deploy this first!
- [s3-free-tier](../s3-free-tier/) - Trigger Lambda from S3
- [dynamodb-free-tier](../dynamodb-free-tier/) - Lambda with DynamoDB

## Further Reading

- [AWS Lambda Free Tier](https://aws.amazon.com/lambda/pricing/)
- [Lambda Developer Guide](https://docs.aws.amazon.com/lambda/)
- [Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)

---

**Remember**: Deploy [billing-alerts](../billing-alerts/) first! 🛡️
