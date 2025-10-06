# AWS Free Tier Modules

Terraform modules for deploying AWS resources within the free tier limits.

## 🆓 AWS Free Tier Overview

AWS offers a free tier with three different types:
1. **Always Free**: Services that are always free within certain limits
2. **12 Months Free**: Free for 12 months from account creation
3. **Trials**: Short-term free trials for specific services

## 📦 Available Modules

### Billing & Monitoring (DEPLOY FIRST!)
- **billing-alerts**: CloudWatch billing alarms and SNS notifications
  - Status: ✅ Complete
  - Critical: Deploy before any other resources

### Compute
- **ec2-free-tier**: EC2 t2.micro/t3.micro instances (750 hrs/month for 12 months)
  - Status: 🔄 In Progress
- **lambda-free-tier**: AWS Lambda functions (1M requests, 400k GB-sec/month)
  - Status: 🔄 In Progress

### Storage
- **s3-free-tier**: S3 buckets (5GB storage, 20k GET, 2k PUT for 12 months)
  - Status: 🔄 In Progress
- **dynamodb-free-tier**: DynamoDB tables (25GB storage, 25 RCU/WCU always free)
  - Status: 🔄 In Progress

### Database
- **rds-free-tier**: RDS instances (750 hrs db.t2.micro, 20GB storage for 12 months)
  - Status: 🔄 In Progress

### Networking
- **vpc-free-tier**: VPC with subnets and security groups (always free)
  - Status: 🔄 In Progress

### Examples
- **examples/**: Complete working examples combining multiple modules
  - Status: 🔄 In Progress

## 🚀 Quick Start

### 1. Set Up Billing Alerts First

**This is critical! Always deploy billing protection before any other resources.**

```hcl
module "billing_alerts" {
  source = "./aws/billing-alerts"
  
  email_address     = "your-email@example.com"
  monthly_threshold = 10.0
  currency          = "USD"
}
```

### 2. Deploy Free Tier Resources

After billing alerts are configured, deploy other resources:

```hcl
module "free_ec2" {
  source = "./aws/ec2-free-tier"
  
  instance_name = "my-free-server"
  instance_type = "t2.micro"  # or t3.micro
  ami_id        = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2
  key_name      = "my-key"
}

module "free_s3" {
  source = "./aws/s3-free-tier"
  
  bucket_name = "my-unique-bucket-name"
}
```

## ⚠️ Important Considerations

### Free Tier Limits

| Service | Free Tier Limit | Duration | Notes |
|---------|----------------|----------|-------|
| EC2 | 750 hrs/month t2.micro | 12 months | Linux/Windows, specific regions |
| S3 | 5GB storage, 20k GET, 2k PUT | 12 months | Standard storage class |
| RDS | 750 hrs/month db.t2.micro, 20GB | 12 months | Single-AZ, specific engines |
| Lambda | 1M requests, 400k GB-sec | Always Free | Memory/duration dependent |
| DynamoDB | 25GB storage, 25 RCU/WCU | Always Free | On-demand or provisioned |
| CloudWatch | 10 metrics, 10 alarms | Always Free | Basic monitoring |
| SNS | 1M publishes, 100k HTTP, 1k email | Always Free | Notifications |
| VPC | First VPC per region | Always Free | Basic components |

### Regional Availability
- Free tier availability varies by region
- t2.micro: Most regions
- t3.micro: Newer regions (may replace t2.micro)
- Some services not available in all regions

### Cost Warnings
Charges will occur if you:
- ❌ Exceed free tier limits
- ❌ Use non-free instance types (t2.small, t2.medium, etc.)
- ❌ Use EBS volumes beyond free tier (30GB gp2/gp3)
- ❌ Use Elastic IPs not attached to running instances
- ❌ Use NAT Gateways (not free)
- ❌ Transfer data out beyond free limits (100GB/month for 12 months)
- ❌ Use RDS Multi-AZ deployments
- ❌ Keep resources running beyond free tier period

## 🛡️ Billing Protection Strategy

1. **Enable Billing Alerts**: Use the billing-alerts module
2. **Set Conservative Limits**: Set alerts well below actual free tier limits
3. **Monitor Daily**: Check AWS Cost Explorer regularly
4. **Use AWS Budgets**: Set up budgets in AWS console
5. **Tag Resources**: Tag all resources for cost tracking
6. **Auto-Shutdown**: Consider Lambda functions to stop resources during off-hours

## 📋 Prerequisites

### Required Tools
- Terraform >= 1.0.0
- AWS CLI configured
- Valid AWS account

### AWS Configuration

Configure AWS credentials using one of these methods:

**Option 1: AWS CLI**
```bash
aws configure
```

**Option 2: Environment Variables**
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

**Option 3: IAM Role (EC2/ECS)**
- Attach IAM role to compute instance

### Required IAM Permissions

Minimum permissions needed (adjust per module):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "ec2:RunInstances",
        "ec2:TerminateInstances",
        "s3:CreateBucket",
        "s3:PutObject",
        "s3:GetObject",
        "cloudwatch:PutMetricAlarm",
        "sns:CreateTopic",
        "sns:Subscribe"
      ],
      "Resource": "*"
    }
  ]
}
```

## 🔧 Module Usage Patterns

### Single Module
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "my_module" {
  source = "./aws/module-name"
  # ... module variables
}
```

### Multiple Modules
```hcl
# First: Billing protection
module "billing" {
  source = "./aws/billing-alerts"
  email_address = "admin@example.com"
  monthly_threshold = 5.0
}

# Then: Resources
module "vpc" {
  source = "./aws/vpc-free-tier"
  vpc_name = "my-vpc"
}

module "ec2" {
  source = "./aws/ec2-free-tier"
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_ids[0]
}
```

## 🧪 Testing

Each module includes:
- Terraform validation
- Example configurations
- Security scanning (tfsec)

Run tests:
```bash
cd aws/module-name
terraform init
terraform validate
terraform plan
```

## 🔒 Security Best Practices

1. **Never commit credentials** - Use AWS credential providers
2. **Use specific AMIs** - Don't use latest, specify exact versions
3. **Implement least privilege** - Minimal IAM permissions
4. **Enable encryption** - All storage should be encrypted
5. **Use security groups wisely** - Limit ingress rules
6. **Enable VPC Flow Logs** - Monitor network traffic (within free tier)
7. **Use AWS Systems Manager** - For secure instance access (free)

## 📚 Additional Resources

- [AWS Free Tier Details](https://aws.amazon.com/free/)
- [AWS Free Tier FAQs](https://aws.amazon.com/free/free-tier-faqs/)
- [AWS Cost Management](https://aws.amazon.com/aws-cost-management/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 🐛 Troubleshooting

### Common Issues

**Issue**: Free tier limits exceeded
- **Solution**: Check AWS Cost Explorer, review resource usage

**Issue**: Billing alerts not receiving notifications
- **Solution**: Confirm SNS subscription, check spam folder

**Issue**: Can't deploy in region
- **Solution**: Some free tier resources only in specific regions

**Issue**: Resources not in free tier
- **Solution**: Verify instance types, storage sizes match free tier specs

## 📞 Support

- GitHub Issues: [Report bugs or request features](https://github.com/lstasi/taf/issues)
- AWS Support: For AWS-specific questions

## 🗺️ Roadmap

See [TODO.md](../TODO.md) for detailed implementation status.

---

**Remember**: Always deploy billing-alerts module first! 🛡️
