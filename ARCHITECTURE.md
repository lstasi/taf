# Terraform Always Free (TAF) - Architecture

## Overview

Terraform Always Free (TAF) is a collection of Terraform modules designed to deploy and manage free-tier resources across multiple cloud providers. The project aims to help developers and learners maximize cloud resources without incurring costs, while maintaining visibility and control over potential billing through automated monitoring and alerts.

## Core Principles

1. **Zero Cost by Default**: All modules deploy only resources that fall within free-tier limits
2. **Safety First**: Every provider includes billing monitors and alerts to prevent unexpected charges
3. **Modular Design**: Each resource type is isolated in its own module for flexibility
4. **Provider Agnostic**: Consistent structure across all cloud providers
5. **Production Ready**: Follows Terraform best practices and includes proper documentation

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
│   ├── ec2-free-tier/          # EC2 t2.micro/t3.micro instances
│   ├── s3-free-tier/           # S3 with free tier limits
│   ├── rds-free-tier/          # RDS db.t2.micro/db.t3.micro
│   ├── lambda-free-tier/       # Lambda with free tier limits
│   ├── vpc-free-tier/          # VPC and networking
│   ├── dynamodb-free-tier/     # DynamoDB free tier
│   └── examples/               # Complete usage examples
├── azure/                       # Azure provider modules
│   ├── README.md
│   ├── billing-alerts/
│   ├── vm-free-tier/
│   ├── storage-free-tier/
│   ├── sql-free-tier/
│   └── examples/
├── gcp/                         # Google Cloud Platform modules
│   ├── README.md
│   ├── billing-alerts/
│   ├── compute-free-tier/
│   ├── storage-free-tier/
│   ├── cloud-functions-free-tier/
│   └── examples/
├── digitalocean/                # DigitalOcean modules
│   ├── README.md
│   ├── billing-alerts/
│   └── examples/
├── cloudflare/                  # Cloudflare modules
│   ├── README.md
│   ├── dns-free-tier/
│   ├── workers-free-tier/
│   ├── pages-free-tier/
│   └── examples/
└── .github/
    └── workflows/
        └── terraform-validate.yml  # CI/CD validation
```

### Module Structure

Each module follows a standard Terraform module structure:

```
module-name/
├── main.tf           # Primary resource definitions
├── variables.tf      # Input variables with descriptions and defaults
├── outputs.tf        # Output values for module composition
├── versions.tf       # Required provider versions
├── README.md         # Module documentation with usage examples
└── examples/         # Example configurations
    └── basic/
        ├── main.tf
        └── README.md
```

## Provider-Specific Implementation

### AWS Free Tier

**Key Free Tier Resources:**
- EC2: 750 hours/month of t2.micro (or t3.micro in some regions)
- S3: 5GB storage, 20,000 GET requests, 2,000 PUT requests
- RDS: 750 hours/month of db.t2.micro, 20GB storage
- Lambda: 1M requests/month, 400,000 GB-seconds compute
- DynamoDB: 25GB storage, 25 WCU, 25 RCU
- CloudWatch: 10 custom metrics, 10 alarms
- VPC: First VPC and basic networking features

**Billing Protection:**
- CloudWatch billing alarms with SNS notifications
- Budget alerts via AWS Budgets API
- Cost anomaly detection
- Daily cost tracking dashboard

### Azure Free Tier

**Key Free Tier Resources:**
- Virtual Machines: B1S instance (750 hours/month)
- Storage: 5GB LRS blob storage
- SQL Database: 250GB managed instance
- Functions: 1M executions/month
- App Service: 10 web apps

**Billing Protection:**
- Azure Cost Management alerts
- Budget thresholds with action groups
- Cost analysis dashboards

### Google Cloud Platform Free Tier

**Key Free Tier Resources:**
- Compute Engine: e2-micro instance (1 per month)
- Cloud Storage: 5GB standard storage
- Cloud Functions: 2M invocations/month
- Cloud Run: 2M requests/month
- Firestore: 1GB storage

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
