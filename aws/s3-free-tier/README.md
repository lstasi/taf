# AWS S3 Free Tier Module

Terraform module for deploying S3 buckets within AWS free tier limits.

## AWS Free Tier Limits

- **5 GB** of standard storage for 12 months
- **20,000 GET** requests per month
- **2,000 PUT** requests per month
- **100 GB** data transfer out for 12 months

## Features

- ✅ Secure by default (public access blocked)
- ✅ Server-side encryption (AES256 or KMS)
- ✅ Optional versioning
- ✅ Lifecycle rules for cost management
- ✅ Static website hosting
- ✅ CORS configuration
- ✅ Request monitoring with CloudWatch alarms
- ✅ Access logging support

## Usage

### Basic Example

```hcl
module "my_bucket" {
  source = "./aws/s3-free-tier"
  
  bucket_name = "my-unique-bucket-name-12345"
}
```

### Static Website Example

```hcl
module "website_bucket" {
  source = "./aws/s3-free-tier"
  
  bucket_name         = "my-website-bucket-12345"
  block_public_access = false  # Required for public website
  enable_website      = true
  
  # Connect to billing alerts
  enable_request_alarm = true
  alarm_actions        = [module.billing_alerts.sns_topic_arn]
  
  tags = {
    Purpose = "static-website"
  }
}
```

### Advanced Example with Lifecycle Rules

```hcl
module "storage_bucket" {
  source = "./aws/s3-free-tier"
  
  bucket_name = "my-storage-bucket-12345"
  
  # Security
  block_public_access = true
  kms_key_id          = aws_kms_key.s3.id
  
  # Versioning and lifecycle
  enable_versioning    = true
  enable_lifecycle_rules = true
  noncurrent_version_expiration_days = 30
  object_expiration_days = 365  # Auto-delete old files
  
  # Cost optimization
  enable_intelligent_tiering = true
  intelligent_tiering_days   = 30
  
  # CORS for web apps
  cors_rules = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["https://example.com"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]
  
  # Monitoring
  enable_request_alarm    = true
  request_alarm_threshold = 500  # Daily limit
  alarm_actions           = [module.billing_alerts.sns_topic_arn]
  
  tags = {
    Environment = "production"
    CostCenter  = "engineering"
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
| bucket_name | Globally unique bucket name | `string` | n/a | yes |
| force_destroy | Allow destroy with objects | `bool` | `false` | no |
| block_public_access | Block public access | `bool` | `true` | no |
| kms_key_id | KMS key for encryption | `string` | `""` | no |
| enable_versioning | Enable versioning | `bool` | `false` | no |
| enable_lifecycle_rules | Enable lifecycle rules | `bool` | `true` | no |
| noncurrent_version_expiration_days | Days to keep old versions | `number` | `90` | no |
| object_expiration_days | Days before object deletion | `number` | `0` | no |
| enable_glacier_transition | Transition to Glacier | `bool` | `false` | no |
| glacier_transition_days | Days before Glacier transition | `number` | `90` | no |
| enable_intelligent_tiering | Enable Intelligent-Tiering | `bool` | `false` | no |
| intelligent_tiering_days | Days before tiering | `number` | `30` | no |
| logging_bucket | Target bucket for logs | `string` | `""` | no |
| cors_rules | CORS configuration | `list(object)` | `[]` | no |
| enable_website | Enable static website | `bool` | `false` | no |
| website_index_document | Index document | `string` | `"index.html"` | no |
| website_error_document | Error document | `string` | `"error.html"` | no |
| enable_request_alarm | Enable request alarm | `bool` | `true` | no |
| request_alarm_threshold | Daily request threshold | `number` | `600` | no |
| alarm_actions | SNS topic ARNs for alarms | `list(string)` | `[]` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | S3 bucket ID |
| bucket_arn | S3 bucket ARN |
| bucket_domain_name | Bucket domain name |
| bucket_regional_domain_name | Regional domain name |
| bucket_region | Bucket region |
| website_endpoint | Website endpoint (if enabled) |
| website_domain | Website domain (if enabled) |
| versioning_enabled | Versioning status |
| free_tier_info | Free tier limits info |

## Important Notes

### Bucket Naming

Bucket names must be:
- Globally unique across all AWS accounts
- 3-63 characters long
- Lowercase letters, numbers, and hyphens only
- Start and end with letter or number

### Cost Warnings

Charges occur for:
- ❌ **Storage beyond 5 GB** ($0.023/GB in us-east-1)
- ❌ **Requests beyond limits** ($0.0004/1000 GET, $0.005/1000 PUT)
- ❌ **Data transfer out** beyond 100 GB ($0.09/GB)
- ❌ **Glacier storage** (different pricing)
- ❌ **Replication** to other regions
- ❌ **Versioning** (old versions count toward storage)

### Security Best Practices

1. **Block Public Access**: Keep `block_public_access = true` unless hosting a website
2. **Enable Encryption**: Use default AES256 or KMS encryption
3. **Bucket Policies**: Restrict access with IAM policies
4. **Access Logging**: Enable for security audits (separate bucket needed)
5. **Versioning**: Protect against accidental deletion (but costs storage)

### Static Website Hosting

To host a static website:

```hcl
module "website" {
  source = "./aws/s3-free-tier"
  
  bucket_name         = "my-website-12345"
  block_public_access = false
  enable_website      = true
}
```

Then upload your files:
```bash
aws s3 cp index.html s3://my-website-12345/
aws s3 cp error.html s3://my-website-12345/
```

Access at: `http://my-website-12345.s3-website-us-east-1.amazonaws.com`

### Lifecycle Rules

Optimize costs with lifecycle rules:
- **Expire old objects**: Automatically delete files after N days
- **Delete old versions**: Remove noncurrent versions
- **Intelligent-Tiering**: Automatic cost optimization
- **Glacier**: Cheaper archival storage (not in free tier)

## Examples

### Upload Files

```bash
# Upload a file
aws s3 cp file.txt s3://bucket-name/

# Upload directory
aws s3 sync ./local-dir s3://bucket-name/

# List objects
aws s3 ls s3://bucket-name/
```

### Configure AWS CLI

```bash
aws configure set default.s3.max_concurrent_requests 10
aws configure set default.s3.multipart_threshold 64MB
```

## Troubleshooting

### Bucket Name Already Taken

Bucket names are globally unique. Try adding:
- Your account ID
- Random numbers
- Region identifier

### Can't Access Website

1. Verify `block_public_access = false`
2. Check bucket policy allows public reads
3. Ensure `index.html` exists in bucket
4. Wait a few minutes for DNS propagation

### High Costs

1. Check storage size: `aws s3 ls --summarize --recursive s3://bucket-name`
2. Review request metrics in CloudWatch
3. Verify lifecycle rules are active
4. Delete old versions if versioning enabled

## Related Modules

- [billing-alerts](../billing-alerts/) - Deploy this first!
- [lambda-free-tier](../lambda-free-tier/) - Process S3 events
- [ec2-free-tier](../ec2-free-tier/) - Access S3 from EC2

## Further Reading

- [AWS S3 Free Tier](https://aws.amazon.com/free/)
- [S3 User Guide](https://docs.aws.amazon.com/s3/)
- [S3 Pricing](https://aws.amazon.com/s3/pricing/)

---

**Remember**: Deploy [billing-alerts](../billing-alerts/) first! 🛡️
