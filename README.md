# Terraform Always Free (TAF)

A comprehensive collection of Terraform modules for deploying **always-free** (perpetually free) resources across multiple cloud providers with built-in billing protection.

## 🎯 Overview

Terraform Always Free (TAF) helps developers and learners maximize cloud resources without incurring costs. This project focuses **exclusively on resources that are always free**, not temporary 12-month free tier offerings.

**Current Phase**: Documentation and architecture design

This project provides:

- **Comprehensive documentation** for always-free resources across AWS, Azure, GCP, DigitalOcean, and Cloudflare
- **Architecture guidelines** for deploying always-free infrastructure
- **Billing protection strategies** to prevent unexpected charges
- **Best practices** for cost-conscious cloud deployments

## ✨ Key Features

- 🆓 **Always Free Only**: Focus exclusively on perpetually free resources (not 12-month trials)
- 🛡️ **Billing Protection**: Automatic alerts and monitoring strategies for each provider
- 📦 **Modular Design**: Documentation organized by resource type for flexibility
- 🌍 **Multi-Cloud Support**: Consistent structure across all providers
- 📚 **Documentation First**: Comprehensive guides before implementation

## 🏗️ Project Structure

```
taf/
├── aws/              # AWS always-free resources documentation
├── azure/            # Azure always-free resources documentation
├── gcp/              # Google Cloud Platform always-free documentation
├── digitalocean/     # DigitalOcean documentation
├── cloudflare/       # Cloudflare always-free documentation
├── ARCHITECTURE.md   # Detailed architecture documentation
└── TODO.md          # Implementation roadmap
```

## 🚀 Getting Started

### Current Phase: Documentation

We are currently in the **documentation phase**, creating comprehensive guides for always-free resources across cloud providers.

**What's Available Now:**
- Architecture documentation (ARCHITECTURE.md)
- Implementation roadmap (TODO.md)
- Provider-specific documentation in each directory

**Coming Soon:**
- Terraform modules implementing the documented patterns
- Example configurations
- CI/CD validation workflows

### How to Use This Repository

1. **Review the Architecture**: Start with [ARCHITECTURE.md](ARCHITECTURE.md) to understand the project structure and always-free resource focus

2. **Check the Roadmap**: See [TODO.md](TODO.md) for implementation status and priorities

3. **Explore Provider Documentation**: Navigate to provider directories (e.g., `aws/`, `gcp/`) to learn about always-free resources

4. **Understand Always-Free vs 12-Month Free**:
   - ✅ **Always Free**: Perpetually free resources (focus of this project)
   - ❌ **12-Month Free**: Temporary free tier (explicitly excluded)

## 📋 Always-Free Resources Coverage

### AWS (Always Free)
- 📝 CloudWatch Billing Alerts
- 📝 Lambda (1M requests/month, 400k GB-seconds)
- 📝 DynamoDB (25GB storage, 25 WCU/RCU)
- 📝 CloudWatch (10 metrics, 10 alarms)
- 📝 SNS (1k emails/month)
- 📝 SQS (1M requests/month)
- 📝 Step Functions (4k transitions/month)

**Excluded**: EC2, S3, RDS (12-month free tier only)

### Azure (Always Free)
- 📝 Functions (1M executions/month)
- 📝 Cosmos DB (1k RU/s, 25GB)
- 📝 Event Grid (100k operations/month)
- 📝 Service Bus (750 hours/month)

**Excluded**: VMs, Storage, SQL Database (12-month free tier only)

### Google Cloud Platform (Always Free)
- 📝 Cloud Functions (2M invocations/month)
- 📝 Cloud Run (2M requests/month)
- 📝 Firestore (1GB storage, 50k reads, 20k writes daily)
- 📝 Cloud Storage (5GB-months)
- 📝 BigQuery (1TB queries/month, 10GB storage)

**Excluded**: Compute Engine e2-micro (12-month free tier only)
- 🔄 Compute Engine (e2-micro)
- 🔄 Cloud Storage (5GB)
- 🔄 Cloud Functions
- 🔄 Firestore

### DigitalOcean
**Note**: DigitalOcean doesn't have traditional always-free resources. They offer:
- $200 credit for new accounts (60 days)
- Free monitoring and insights tools

### Cloudflare (Always Free)
- 📝 DNS (Unlimited queries)
- 📝 CDN (Unlimited bandwidth)
- 📝 Workers (100k requests/day)
- 📝 Pages (Unlimited sites)
- 📝 SSL Certificates (Universal SSL)

Legend: 📝 Documentation Phase | 🔄 Implementation In Progress | ✅ Complete

## 📖 Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) - Detailed architecture and design decisions
- [TODO.md](TODO.md) - Implementation roadmap and progress tracking
- Provider-specific READMEs in each provider directory
- Module-specific documentation in each module directory

## 📚 Documentation Structure

Each provider directory contains:
- **README.md**: Overview of always-free resources for that provider
- **Module directories**: Specific resource documentation (e.g., `lambda/`, `dynamodb/`)
- **examples/**: Planned usage examples and patterns

Each module documentation includes:
- Always-free resource limits and constraints
- Use cases and best practices
- Cost warnings and monitoring strategies
- Configuration guidelines (for future implementation)

## ⚠️ Important: Always Free vs 12-Month Free Tier

This project **exclusively focuses on always-free resources**. We explicitly exclude:

### ❌ Excluded (12-Month Free Tier Only)
- AWS EC2 t2.micro/t3.micro instances
- AWS S3 storage (5GB)
- AWS RDS databases
- Azure Virtual Machines (B1S)
- Azure Blob Storage
- GCP Compute Engine e2-micro

### ✅ Included (Always Free)
- AWS Lambda, DynamoDB, CloudWatch, SNS
- Azure Functions, Cosmos DB, Event Grid
- GCP Cloud Functions, Cloud Run, Firestore
- Cloudflare DNS, CDN, Workers, Pages

### Why This Matters
**12-month free tier** offerings expire after one year, potentially leading to unexpected charges. **Always-free** resources remain free indefinitely within specified usage limits, making them ideal for:
- Long-term learning projects
- Low-traffic production workloads
- Permanent infrastructure components
- Cost-conscious development

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

**Current Phase**: Documentation and architecture design
**Next Phase**: Terraform module implementation for AWS always-free resources

---

**⚡ Getting Started**: 
1. Read [ARCHITECTURE.md](ARCHITECTURE.md) to understand the always-free focus and project structure
2. Check [TODO.md](TODO.md) for implementation status and priorities
3. Explore provider directories (e.g., `aws/`) for always-free resource documentation
4. Understand the critical distinction between always-free and 12-month free tier resources
