# Terraform Always Free (TAF)

A comprehensive collection of Terraform modules for deploying free-tier resources across multiple cloud providers with built-in billing protection.

## 🎯 Overview

Terraform Always Free (TAF) helps developers and learners maximize cloud resources without incurring costs. This project provides:

- **Pre-configured Terraform modules** for free-tier resources across AWS, Azure, GCP, DigitalOcean, and Cloudflare
- **Automated billing alerts** to prevent unexpected charges
- **Production-ready configurations** following best practices
- **Comprehensive documentation** and examples for each module

## ✨ Key Features

- 🆓 **Zero Cost by Default**: All modules stay within free-tier limits
- 🛡️ **Billing Protection**: Automatic alerts and monitoring for each provider
- 📦 **Modular Design**: Use only what you need, compose as required
- 🌍 **Multi-Cloud Support**: Consistent structure across all providers
- 📚 **Well Documented**: Each module includes usage examples and documentation

## 🏗️ Project Structure

```
taf/
├── aws/              # AWS free tier modules
├── azure/            # Azure free tier modules
├── gcp/              # Google Cloud Platform modules
├── digitalocean/     # DigitalOcean modules
├── cloudflare/       # Cloudflare modules
├── ARCHITECTURE.md   # Detailed architecture documentation
└── TODO.md          # Implementation roadmap
```

## 🚀 Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- Cloud provider account (AWS, Azure, GCP, etc.)
- Appropriate cloud provider credentials configured

### Basic Usage

1. Clone this repository:
```bash
git clone https://github.com/lstasi/taf.git
cd taf
```

2. Navigate to your desired provider and module:
```bash
cd aws/ec2-free-tier
```

3. Review the module documentation and customize variables:
```bash
cat README.md
```

4. Deploy the module (example):
```hcl
module "free_ec2" {
  source = "./aws/ec2-free-tier"
  
  instance_name = "my-free-instance"
  region        = "us-east-1"
}
```

5. **Always deploy billing alerts first**:
```hcl
module "billing_alerts" {
  source = "./aws/billing-alerts"
  
  email_address     = "your-email@example.com"
  monthly_threshold = 10  # Alert if costs exceed $10/month
}
```

## 📋 Provider Coverage

### AWS
- ✅ CloudWatch Billing Alerts
- 🔄 EC2 (t2.micro/t3.micro)
- 🔄 S3 (5GB storage)
- 🔄 Lambda (1M requests/month)
- 🔄 RDS (db.t2.micro)
- 🔄 DynamoDB (25GB)
- 🔄 VPC & Networking

### Azure
- 🔄 Cost Management Alerts
- 🔄 VM (B1S instance)
- 🔄 Storage (5GB blob)
- 🔄 Functions
- 🔄 SQL Database

### Google Cloud Platform
- 🔄 Budget Alerts
- 🔄 Compute Engine (e2-micro)
- 🔄 Cloud Storage (5GB)
- 🔄 Cloud Functions
- 🔄 Firestore

### DigitalOcean
- 🔄 Usage Alerts
- 🔄 Minimal Droplets
- 🔄 VPC

### Cloudflare
- 🔄 DNS (Unlimited)
- 🔄 CDN (Unlimited bandwidth)
- 🔄 Workers (100k requests/day)
- 🔄 Pages (Unlimited sites)

Legend: ✅ Complete | 🔄 In Progress | ⏸️ Planned

## 📖 Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) - Detailed architecture and design decisions
- [TODO.md](TODO.md) - Implementation roadmap and progress tracking
- Provider-specific READMEs in each provider directory
- Module-specific documentation in each module directory

## 🛠️ Available Modules

Each module includes:
- Terraform configuration files
- Variable definitions with sensible defaults
- Output values for module composition
- Comprehensive README with examples
- Free-tier limit enforcement

## ⚠️ Important Notes

### Billing Protection
While these modules are designed to stay within free-tier limits, you should:
1. **Always deploy billing alerts first** before any other resources
2. Monitor your cloud provider console regularly
3. Understand your provider's free-tier limitations
4. Set up multi-channel alerts (email, SMS, Slack)
5. Review costs weekly, especially when learning

### Free Tier Limits
Free-tier offerings vary by:
- **Region**: Some resources are only free in specific regions
- **Time**: Many free tiers are limited to 12 months for new accounts
- **Always Free vs Trial**: Some resources are always free, others are trial-only
- **Usage Patterns**: Exceeding request/storage limits will incur charges

### Security Considerations
- Never commit credentials or sensitive data
- Use environment variables or secure secret management
- Follow least-privilege principle for IAM/RBAC
- Enable encryption at rest and in transit
- Regularly review security group rules

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Follow the existing module structure
4. Include documentation and examples
5. Test thoroughly in a sandbox environment
6. Submit a pull request

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed contribution guidelines.

## 📜 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Cloud provider documentation and free-tier programs
- Terraform community and best practices
- Contributors and users of this project

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/lstasi/taf/issues)
- **Discussions**: [GitHub Discussions](https://github.com/lstasi/taf/discussions)
- **Documentation**: See ARCHITECTURE.md and module READMEs

## 🗺️ Roadmap

See [TODO.md](TODO.md) for the complete implementation roadmap.

**Current Focus**: AWS provider modules and billing protection

---

**⚡ Getting Started**: Begin with [ARCHITECTURE.md](ARCHITECTURE.md) to understand the project structure, then check [TODO.md](TODO.md) for implementation status.
