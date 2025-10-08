# AWS Always Free Resources

Documentation and (planned) Terraform modules for deploying AWS **always-free** resources.

## 🎯 Focus: Always Free Only

This project focuses **exclusively on AWS resources that are perpetually free** (not 12-month free tier offerings).

**Current Phase**: Documentation

AWS offers several types of free resources:
- ✅ **Always Free**: Services that are perpetually free within certain limits (FOCUS OF THIS PROJECT)
- ❌ **12 Months Free**: Free for 12 months from account creation (EXPLICITLY EXCLUDED)
- ❌ **Trials**: Short-term free trials for specific services (EXPLICITLY EXCLUDED)

## 📦 Always Free Resources (Documented)

### Billing & Monitoring
- **billing-alerts**: CloudWatch billing alarms and SNS notifications
  - Status: 📝 Documentation phase
  - Critical: Always deploy billing protection

### Compute (Always Free)
- **lambda**: AWS Lambda functions
  - Limit: 1M requests/month, 400,000 GB-seconds compute
  - Status: 📝 Documentation phase

### Storage (Always Free)
- **dynamodb**: DynamoDB tables
  - Limit: 25GB storage, 25 WCU, 25 RCU
  - Status: 📝 Documentation phase

### Monitoring (Always Free)
- **cloudwatch**: CloudWatch metrics and alarms
  - Limit: 10 custom metrics, 10 alarms, 5GB log ingestion
  - Status: 📝 Documentation phase

### Messaging (Always Free)
- **sns**: Simple Notification Service
  - Limit: 1,000 email publishes/month, 1M mobile push notifications
  - Status: 📝 Documentation phase

- **sqs**: Simple Queue Service
  - Limit: 1M requests/month
  - Status: 📝 Documentation phase

### Orchestration (Always Free)
- **step-functions**: Step Functions state machines
  - Limit: 4,000 state transitions/month
  - Status: 📝 Documentation phase

## ❌ Explicitly Excluded (12-Month Free Tier Only)

The following AWS resources are **NOT included** in this project as they are only free for the first 12 months:

- **EC2 instances** (t2.micro/t3.micro) - 750 hours/month for 12 months only
- **S3 storage** - 5GB for 12 months only  
- **RDS databases** - 750 hours db.t2.micro for 12 months only
- **EBS volumes** - 30GB for 12 months only
- **VPC** - Basic components are always free, but not focus of this project

## 📖 Documentation Structure

Each module directory contains comprehensive documentation including:
- Always-free limits and constraints
- Use cases and best practices
- Cost warnings and monitoring strategies
- Configuration guidelines for future implementation

**Current Phase**: We are building comprehensive documentation before implementing Terraform code.

## ⚠️ Always Free Limits

| Service | Always Free Limit | Perpetual | Notes |
|---------|-------------------|-----------|-------|
| **Lambda** | 1M requests/month, 400k GB-sec | ✅ Yes | Memory × duration dependent |
| **DynamoDB** | 25GB storage, 25 RCU/WCU | ✅ Yes | On-demand or provisioned |
| **CloudWatch** | 10 metrics, 10 alarms, 5GB logs | ✅ Yes | Basic monitoring |
| **SNS** | 1k email publishes, 1M mobile push | ✅ Yes | Notifications |
| **SQS** | 1M requests/month | ✅ Yes | Standard queues |
| **Step Functions** | 4k state transitions/month | ✅ Yes | Standard workflows |
| **CloudFormation** | 1k handler operations/month | ✅ Yes | Infrastructure as Code |
| **Data Transfer Out** | 100GB/month to internet | ✅ Yes | Aggregate across services |

### Why No EC2, S3, or RDS?

These popular services are only free for 12 months:
- **EC2 t2.micro/t3.micro**: 750 hours/month for first 12 months only
- **S3**: 5GB storage for first 12 months only
- **RDS db.t2.micro**: 750 hours/month for first 12 months only

After 12 months, they start incurring charges. This project focuses on resources that remain free indefinitely.

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
