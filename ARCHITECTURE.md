# Terraform Always Free (TAF) - Architecture

## Overview

Terraform Always Free (TAF) is a collection of Terraform modules designed to deploy and manage **always-free** resources across multiple cloud providers. The project focuses exclusively on resources that are perpetually free (not limited to 12-month trials), helping developers and learners maximize cloud resources without incurring costs, while maintaining visibility and control over potential billing through automated monitoring and alerts.

## Core Principles

1. **Always Free Only**: Focus exclusively on resources that are perpetually free, not temporary 12-month free tier offerings
2. **Zero Cost by Default**: All modules deploy only resources that fall within always-free limits
3. **Safety First**: Every provider includes billing monitors and alerts to prevent unexpected charges
4. **Modular Design**: Each resource type is isolated in its own module for flexibility
5. **Provider Agnostic**: Consistent structure across all cloud providers
6. **Documentation First**: Comprehensive documentation before implementation

## Architecture Structure

### Directory Organization

```
taf/
├── README.md                    # Project overview and quick start
├── ARCHITECTURE.md              # This document
├── TODO.md                      # Implementation tracking
├── aws/                         # AWS provider modules
│   ├── README.md               # AWS-specific documentation
│   ├── billing-alerts/         # CloudWatch billing alerts
│   │   └── README.md           # Module documentation
│   ├── lambda/                 # Lambda functions (always free: 1M requests/month)
│   │   └── README.md
│   ├── dynamodb/               # DynamoDB (always free: 25GB, 25 WCU/RCU)
│   │   └── README.md
│   ├── cloudwatch/             # CloudWatch (always free: 10 metrics, 10 alarms)
│   │   └── README.md
│   ├── sns/                    # SNS (always free: 1k emails/month)
│   │   └── README.md
│   └── examples/               # Complete usage examples
├── azure/                       # Azure provider modules
│   ├── README.md
│   ├── billing-alerts/
│   └── examples/
├── gcp/                         # Google Cloud Platform modules
│   ├── README.md
│   ├── billing-alerts/
│   ├── cloud-functions/        # Cloud Functions (always free: 2M invocations)
│   ├── firestore/              # Firestore (always free: 1GB)
│   └── examples/
├── digitalocean/                # DigitalOcean modules
│   ├── README.md
│   └── examples/
├── cloudflare/                  # Cloudflare modules
│   ├── README.md
│   ├── dns/                    # DNS (always free: unlimited)
│   ├── workers/                # Workers (always free: 100k requests/day)
│   ├── pages/                  # Pages (always free: unlimited sites)
│   └── examples/
└── .github/
    └── workflows/
        └── terraform-validate.yml  # CI/CD validation
```

### Module Structure (Documentation Phase)

Currently in documentation phase. Each module directory contains:

```
module-name/
└── README.md         # Comprehensive module documentation including:
                      #   - Always-free resource limits
                      #   - Use cases and examples
                      #   - Cost warnings and constraints
                      #   - Configuration parameters (planned)
                      #   - Best practices
```

Future implementation will follow standard Terraform module structure with main.tf, variables.tf, outputs.tf, and versions.tf files.

## Provider-Specific Implementation

### AWS Always Free Resources

**Focus on perpetually free resources (no 12-month limit):**
- **Lambda**: 1M requests/month, 400,000 GB-seconds compute
- **DynamoDB**: 25GB storage, 25 WCU, 25 RCU
- **CloudWatch**: 10 custom metrics, 10 alarms, 5GB log ingestion
- **SNS**: 1,000 email deliveries/month, 1M mobile push notifications
- **SQS**: 1M requests/month
- **Step Functions**: 4,000 state transitions/month
- **CloudFormation**: 1,000 handler operations/month
- **Data Transfer**: 100GB/month out to internet (aggregate across all services)

**Explicitly Excluded (12-month free tier only):**
- ❌ EC2 instances (t2.micro/t3.micro - only free for 12 months)
- ❌ S3 storage (5GB - only free for 12 months)
- ❌ RDS databases (db.t2.micro - only free for 12 months)
- ❌ EBS volumes (30GB - only free for 12 months)

**Billing Protection:**
- CloudWatch billing alarms with SNS notifications
- Budget alerts via AWS Budgets API
- Cost anomaly detection
- Daily cost tracking dashboard

### Azure Always Free Resources

**Focus on perpetually free resources:**
- **Functions**: 1M executions/month
- **Cosmos DB**: 1,000 RU/s with 25GB storage
- **Event Grid**: 100,000 operations/month
- **Service Bus**: 750 hours/month
- **Notification Hubs**: 1M pushes/month

**Explicitly Excluded (12-month free tier only):**
- ❌ Virtual Machines (B1S - only free for 12 months)
- ❌ Storage (5GB blob - only free for 12 months)
- ❌ SQL Database (250GB - only free for 12 months)

**Billing Protection:**
- Azure Cost Management alerts
- Budget thresholds with action groups
- Cost analysis dashboards

### Google Cloud Platform Always Free Resources

**Focus on perpetually free resources:**
- **Cloud Functions**: 2M invocations/month
- **Cloud Run**: 2M requests/month, 360,000 GB-seconds
- **Firestore**: 1GB storage, 50K reads, 20K writes per day
- **Cloud Storage**: 5GB-months standard storage (US regions)
- **BigQuery**: 1TB queries/month, 10GB storage

**Explicitly Excluded (12-month free tier only):**
- ❌ Compute Engine (e2-micro - only free for 12 months in some circumstances)

**Billing Protection:**
- Budget alerts with Cloud Monitoring
- Programmatic budget notifications
- Cost breakdown dashboards

### DigitalOcean

**Note:** DigitalOcean doesn't have a traditional free tier, but offers:
- $200 credit for new accounts (60 days)
- Always-free developer tools (monitoring, insights)

**Billing Protection:**
- Usage alerts via API
- Spending limits on account level

### Cloudflare Free Tier

**Key Free Tier Resources:**
- DNS: Unlimited DNS queries
- CDN: Unlimited bandwidth
- Workers: 100,000 requests/day
- Pages: Unlimited sites
- SSL certificates: Universal SSL

**Billing Protection:**
- Workers usage alerts
- R2 storage limits (if applicable)

## Security Considerations

1. **No Hardcoded Credentials**: All modules use provider authentication mechanisms
2. **Least Privilege**: IAM roles and policies follow least-privilege principle
3. **Encrypted Storage**: Default encryption for all storage resources
4. **Network Isolation**: Proper VPC/VNET configuration with security groups
5. **Secret Management**: Integration with native secret managers (AWS Secrets Manager, Azure Key Vault, etc.)

## Usage Patterns

### Single Provider Deployment

```hcl
module "aws_free_tier" {
  source = "./aws/ec2-free-tier"
  
  instance_name = "my-free-instance"
  region        = "us-east-1"
}

module "aws_billing" {
  source = "./aws/billing-alerts"
  
  email_address     = "admin@example.com"
  monthly_threshold = 10  # Alert if costs exceed $10
}
```

### Multi-Provider Deployment

```hcl
# Deploy across multiple providers
module "aws_compute" {
  source = "./aws/ec2-free-tier"
}

module "cloudflare_cdn" {
  source = "./cloudflare/dns-free-tier"
}
```

## Monitoring and Observability

Each provider includes:
1. **Cost Monitoring**: Real-time cost tracking and projections
2. **Resource Monitoring**: Usage metrics for free-tier resources
3. **Alert System**: Multi-channel notifications (email, Slack, etc.)
4. **Dashboards**: Visual representation of resource usage vs. limits

## Testing Strategy

1. **Validation**: Terraform validate and fmt checks
2. **Security Scanning**: tfsec, checkov for security best practices
3. **Cost Estimation**: Infracost integration for cost visibility
4. **Example Testing**: Automated testing of example configurations

## Future Enhancements

1. **Interactive CLI**: Tool to help users select and deploy resources
2. **Dashboard**: Central web dashboard for monitoring all providers
3. **Terraform Cloud Integration**: Remote state and team collaboration
4. **Policy as Code**: OPA policies to prevent non-free-tier resources
5. **Additional Providers**: Oracle Cloud, IBM Cloud, Alibaba Cloud

## Contributing

Contributions are welcome! When adding new modules:
1. Follow the standard module structure
2. Include comprehensive documentation
3. Add billing protection mechanisms
4. Provide working examples
5. Test thoroughly before submitting

## License

MIT License - See LICENSE file for details
