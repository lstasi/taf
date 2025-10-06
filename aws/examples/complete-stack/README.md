# Complete AWS Free Tier Stack Example

This example demonstrates a complete serverless application using AWS free tier resources with comprehensive billing protection.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    AWS Free Tier Stack                   │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────┐        ┌──────────────┐              │
│  │   Billing    │───────▶│     SNS      │              │
│  │   Alarms     │        │    Alerts    │              │
│  └──────────────┘        └──────────────┘              │
│         │                                                │
│         │                                                │
│  ┌──────▼──────────────────────────────────────┐        │
│  │              CloudWatch                     │        │
│  │  (Monitoring all resources)                 │        │
│  └──────┬──────────────────────────────────────┘        │
│         │                                                │
│  ┌──────▼──────┐  ┌────────────┐  ┌────────────┐       │
│  │     S3      │  │   Lambda   │  │    EC2     │       │
│  │  (Website)  │  │    (API)   │  │   (Dev)    │       │
│  │   5 GB      │  │  1M reqs   │  │  750 hrs   │       │
│  └─────────────┘  └────────────┘  └────────────┘       │
│                          │                               │
│                   ┌──────▼──────┐                       │
│                   │     S3      │                       │
│                   │   (Data)    │                       │
│                   └─────────────┘                       │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

## What This Creates

1. **Billing Alerts** (Critical)
   - CloudWatch billing alarms ($5 warning, $10 critical)
   - SNS topic with email notifications
   - AWS Budget with forecasting
   - Per-service cost monitoring

2. **Static Website** (S3)
   - Public S3 bucket configured for website hosting
   - Lifecycle rules to manage storage
   - Request monitoring alarms

3. **Serverless API** (Lambda)
   - Python Lambda function with HTTP endpoint
   - CloudWatch logs (7-day retention)
   - Error, throttle, and invocation alarms
   - S3 read access

4. **Data Storage** (S3)
   - Private S3 bucket for application data
   - S3 event triggers Lambda on upload
   - Encrypted at rest

5. **Development Instance** (EC2 - Optional)
   - t2.micro instance with Amazon Linux 2
   - Apache web server pre-installed
   - CloudWatch monitoring

## Prerequisites

1. **AWS Account** with free tier eligibility
2. **AWS CLI** configured with credentials
3. **Terraform** >= 1.0 installed
4. **SSH Key Pair** (if enabling EC2)

## Usage

### 1. Prepare Lambda Function

Create a simple Lambda function:

```python
# lambda/index.py
import json

def handler(event, context):
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({
            'message': 'Hello from AWS Free Tier!',
            'event': event
        })
    }
```

Package it:
```bash
mkdir -p lambda
cd lambda
zip function.zip index.py
cd ..
```

### 2. Create terraform.tfvars

```hcl
# Required variables
unique_id   = "12345"  # Use your AWS account ID or random number
alert_email = "your-email@example.com"

# Optional variables
project_name      = "my-project"
aws_region        = "us-east-1"
lambda_zip_path   = "./lambda/function.zip"
enable_ec2        = false
ssh_key_name      = ""  # Set if enable_ec2 = true
allowed_ssh_cidr  = ["1.2.3.4/32"]  # Your IP only
```

### 3. Deploy

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy (will take 2-3 minutes)
terraform apply

# Important: Confirm your email subscription!
# Check your email for SNS confirmation
```

### 4. Upload Website Files

Create a simple website:

```html
<!-- index.html -->
<!DOCTYPE html>
<html>
<head>
    <title>AWS Free Tier Demo</title>
</head>
<body>
    <h1>Hello from AWS Free Tier!</h1>
    <button onclick="callApi()">Call API</button>
    <div id="result"></div>
    
    <script>
        async function callApi() {
            const response = await fetch('YOUR_API_URL_HERE');
            const data = await response.json();
            document.getElementById('result').innerText = JSON.stringify(data, null, 2);
        }
    </script>
</body>
</html>
```

```html
<!-- error.html -->
<!DOCTYPE html>
<html>
<head>
    <title>Error</title>
</head>
<body>
    <h1>Page Not Found</h1>
</body>
</html>
```

Upload to S3:
```bash
# Get bucket name from outputs
BUCKET=$(terraform output -raw website_bucket)

# Upload files
aws s3 cp index.html s3://$BUCKET/
aws s3 cp error.html s3://$BUCKET/

# Make them public
aws s3 cp s3://$BUCKET/index.html s3://$BUCKET/index.html --acl public-read
aws s3 cp s3://$BUCKET/error.html s3://$BUCKET/error.html --acl public-read
```

### 5. Test Your Deployment

```bash
# Get outputs
terraform output

# Test website
WEBSITE_URL=$(terraform output -raw website_url)
curl $WEBSITE_URL

# Test API
API_URL=$(terraform output -raw api_url)
curl $API_URL

# Test S3 trigger (upload file to data bucket)
DATA_BUCKET=$(terraform output -raw data_bucket)
echo "test data" > test.txt
aws s3 cp test.txt s3://$DATA_BUCKET/uploads/test.txt

# Check Lambda logs
aws logs tail /aws/lambda/taf-demo-api --follow
```

### 6. Monitor Costs

```bash
# View current month costs
aws ce get-cost-and-usage \
  --time-period Start=$(date +%Y-%m-01),End=$(date +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics BlendedCost

# Check CloudWatch alarms
aws cloudwatch describe-alarms --alarm-names billing-alert

# View AWS Budgets
aws budgets describe-budgets --account-id YOUR_ACCOUNT_ID
```

## Costs

This example is designed to stay **completely free** within the AWS free tier:

| Service | Free Tier Limit | This Example | Status |
|---------|----------------|--------------|--------|
| EC2 | 750 hrs/month | 0-730 hrs | ✅ Free |
| S3 Storage | 5 GB | ~50 MB | ✅ Free |
| S3 Requests | 20k GET, 2k PUT | <1000/month | ✅ Free |
| Lambda | 1M requests | <10k/month | ✅ Free |
| CloudWatch | 10 alarms | 8 alarms | ✅ Free |
| SNS | 1k emails | <100/month | ✅ Free |

**Total Expected Cost: $0.00**

⚠️ Charges will occur if:
- You exceed free tier limits
- You enable EC2 without stopping it (>750 hrs)
- You store more than 5 GB in S3
- You make excessive API calls

## Cleanup

```bash
# Empty S3 buckets first (required)
aws s3 rm s3://$(terraform output -raw website_bucket) --recursive
aws s3 rm s3://$(terraform output -raw data_bucket) --recursive

# Destroy all resources
terraform destroy

# Confirm by typing 'yes'
```

## Customization

### Add More Lambda Functions

```hcl
module "another_function" {
  source = "../../lambda-free-tier"
  
  function_name = "my-function"
  filename      = "./lambda/my-function.zip"
  # ... other settings
}
```

### Enable EC2 Development Instance

Set in terraform.tfvars:
```hcl
enable_ec2   = true
ssh_key_name = "my-key"
```

### Add More Alarms

```hcl
service_thresholds = {
  "Amazon Elastic Compute Cloud - Compute" = 5.0
  "Amazon Simple Storage Service"          = 2.0
  "AWS Lambda"                             = 1.0
  "Amazon DynamoDB"                        = 1.0
  "Amazon CloudFront"                      = 1.0
}
```

## Troubleshooting

### Billing Alerts Not Received

1. Check email spam folder
2. Confirm SNS subscription via email link
3. Wait 6-24 hours for billing data to populate
4. Verify billing alerts enabled in AWS Console

### Website Not Accessible

1. Ensure files are uploaded: `aws s3 ls s3://bucket-name`
2. Check bucket policy allows public read
3. Verify `block_public_access = false`
4. Wait a few minutes for DNS propagation

### Lambda Function Errors

1. Check CloudWatch logs: `aws logs tail /aws/lambda/function-name`
2. Test locally with sample events
3. Verify IAM permissions
4. Check function timeout setting

### EC2 Cannot Connect

1. Verify security group allows your IP
2. Check instance is running: `aws ec2 describe-instances`
3. Ensure SSH key permissions: `chmod 400 key.pem`
4. Try AWS Systems Manager Session Manager (no key needed)

## Best Practices

1. **Always Deploy Billing Alerts First**
2. **Monitor Daily**: Check AWS Cost Explorer
3. **Tag Everything**: Use consistent tags for cost tracking
4. **Set Conservative Limits**: Better to alert early
5. **Test Locally First**: Don't waste Lambda invocations
6. **Use Lifecycle Rules**: Auto-delete old S3 objects
7. **Stop EC2 When Not Needed**: Only run when actively using
8. **Review Weekly**: Check costs every week

## Security Considerations

1. **SSH Access**: Restrict to your IP only
2. **S3 Buckets**: Keep data buckets private
3. **Lambda URLs**: Use AWS_IAM auth for non-public APIs
4. **Secrets**: Use AWS Secrets Manager, not environment variables
5. **IAM**: Follow least-privilege principle
6. **Encryption**: Enable for all data at rest

## Next Steps

1. Add a DynamoDB table for data persistence
2. Set up CloudFront for CDN (free tier)
3. Add API Gateway for more advanced APIs
4. Implement CI/CD with GitHub Actions
5. Add monitoring dashboard

## Further Reading

- [AWS Free Tier](https://aws.amazon.com/free/)
- [Cost Optimization](https://aws.amazon.com/pricing/cost-optimization/)
- [Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

---

**Remember**: Monitor your costs daily and stay within free tier limits! 🛡️
