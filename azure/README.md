# Azure Always Free Resources

Documentation and (planned) Terraform modules for deploying Azure **always-free** resources.

## 🎯 Focus: Always Free Only

This project focuses **exclusively on Azure resources that are perpetually free** (not 12-month free tier offerings).

**Current Phase**: Documentation

Azure offers several types of free resources:
- ✅ **Always Free**: Services that are perpetually free within certain limits (FOCUS OF THIS PROJECT)
- ❌ **12 Months Free**: Free for 12 months from account creation (EXPLICITLY EXCLUDED)
- ❌ **Trials**: Short-term free trials for specific services (EXPLICITLY EXCLUDED)

## 📦 Always Free Resources (Documented)

### Billing & Monitoring
- **billing-alerts**: Azure Cost Management alerts and action groups
  - Status: 📝 Documentation phase
  - Critical: Always deploy billing protection

### Compute (Always Free)
- **functions**: Azure Functions (serverless compute)
  - Limit: 1M executions/month
  - Status: 📝 Documentation phase

### Database (Always Free)
- **cosmos-db**: Azure Cosmos DB
  - Limit: 1,000 RU/s provisioned throughput, 25GB storage
  - Status: 📝 Documentation phase

### Messaging (Always Free)
- **event-grid**: Azure Event Grid
  - Limit: 100,000 operations/month
  - Status: 📝 Documentation phase

- **service-bus**: Azure Service Bus
  - Limit: 750 hours/month (Basic tier)
  - Status: 📝 Documentation phase

- **notification-hubs**: Azure Notification Hubs
  - Limit: 1M push notifications/month
  - Status: 📝 Documentation phase

## ❌ Explicitly Excluded (12-Month Free Tier Only)

The following Azure resources are **NOT included** in this project as they are only free for the first 12 months:

- **Virtual Machines** (B1S) - 750 hours/month Linux for 12 months only
- **Blob Storage** - 5GB LRS hot block for 12 months only
- **SQL Database** - 250GB S0 for 12 months only
- **App Service** - Free tier has limitations, consider for simple use cases
- **Managed Disks** - 64GB×2 P6 SSD for 12 months only

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
| **Azure Functions** | 1M executions/month | ✅ Yes | Consumption plan only |
| **Cosmos DB** | 1,000 RU/s, 25GB | ✅ Yes | Free tier must be enabled |
| **Event Grid** | 100k operations/month | ✅ Yes | System topics free |
| **Service Bus** | 750 hours/month | ✅ Yes | Basic tier |
| **Notification Hubs** | 1M pushes/month | ✅ Yes | Free tier |
| **Active Directory** | 50,000 objects | ✅ Yes | Basic features |
| **Azure DevOps** | 5 users, 1 parallel job | ✅ Yes | Basic plan |
| **Bandwidth** | 5GB egress/month | ✅ Yes | Limited free transfer |

### Why No VMs, Storage, or SQL?

These popular services are only free for 12 months:
- **B1S VMs**: 750 hours/month for first 12 months only
- **Blob Storage**: 5GB for first 12 months only
- **SQL Database**: S0 tier for first 12 months only

After 12 months, they start incurring charges. This project focuses on resources that remain free indefinitely.

### Cost Warnings
Charges will occur if you:
- ❌ Exceed free tier limits
- ❌ Use non-free pricing tiers
- ❌ Deploy in premium regions (some services cost more)
- ❌ Use VNet integration (may incur charges)
- ❌ Enable advanced features beyond free tier
- ❌ Exceed bandwidth limits
- ❌ Keep resources running beyond free tier period

## 🛡️ Billing Protection Strategy

1. **Enable Cost Alerts**: Use the billing-alerts module
2. **Set Conservative Limits**: Set alerts well below actual free tier limits
3. **Monitor Daily**: Check Azure Cost Management regularly
4. **Use Budgets**: Set up budgets in Azure portal
5. **Tag Resources**: Tag all resources for cost tracking
6. **Review Invoices**: Check monthly invoices for unexpected charges

## 📋 Prerequisites

### Required Tools
- Terraform >= 1.0.0
- Azure CLI configured
- Valid Azure subscription

### Azure Configuration

Configure Azure credentials using one of these methods:

**Option 1: Azure CLI**
```bash
az login
az account set --subscription "subscription-id"
```

**Option 2: Service Principal**
```bash
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
```

**Option 3: Managed Identity**
- Use when running on Azure VMs or App Service
- Assign appropriate RBAC roles

### Required Permissions

Minimum RBAC roles needed (adjust per module):
- **Reader**: For viewing resources
- **Contributor**: For creating/modifying resources
- **Cost Management Reader**: For billing alerts

## 🔧 Module Usage Patterns

### Single Module
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "my_module" {
  source = "./azure/module-name"
  # ... module variables
}
```

### Multiple Modules
```hcl
# First: Billing protection
module "billing" {
  source = "./azure/billing-alerts"
  
  email_address     = "admin@example.com"
  monthly_threshold = 5.0
}

# Then: Resources
module "functions" {
  source = "./azure/functions"
  
  function_app_name = "my-function"
  location          = "eastus"
}

module "cosmos_db" {
  source = "./azure/cosmos-db"
  
  account_name = "my-cosmos"
  location     = "eastus"
}
```

## 🧪 Testing

Each module includes:
- Terraform validation
- Example configurations
- Security scanning (tfsec)

Run tests:
```bash
cd azure/module-name
terraform init
terraform validate
terraform plan
```

## 🔒 Security Best Practices

1. **Never commit credentials** - Use Azure credential providers
2. **Use Managed Identities** - Prefer over service principals
3. **Implement least privilege** - Minimal RBAC permissions
4. **Enable encryption** - All storage should be encrypted
5. **Use Private Endpoints** - When connecting to services
6. **Enable Azure Defender** - For security monitoring
7. **Use Azure Key Vault** - For secret management

## 📚 Additional Resources

- [Azure Free Account](https://azure.microsoft.com/free/)
- [Azure Free Services](https://azure.microsoft.com/free/free-account-faq/)
- [Azure Cost Management](https://azure.microsoft.com/services/cost-management/)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## 🐛 Troubleshooting

### Common Issues

**Issue**: Free tier limits exceeded
- **Solution**: Check Azure Cost Management, review resource usage

**Issue**: Cost alerts not receiving notifications
- **Solution**: Confirm action group configuration, check email/webhook settings

**Issue**: Can't deploy in region
- **Solution**: Some free tier resources only in specific regions

**Issue**: Resources not in free tier
- **Solution**: Verify pricing tiers match free tier specs

**Issue**: Cosmos DB free tier not available
- **Solution**: Only one free tier Cosmos DB per subscription; check existing accounts

## 📞 Support

- GitHub Issues: [Report bugs or request features](https://github.com/lstasi/taf/issues)
- Azure Support: For Azure-specific questions
- Azure Documentation: [Official Azure Docs](https://docs.microsoft.com/azure/)

## 🗺️ Roadmap

See [TODO.md](../TODO.md) for detailed implementation status.

---

**Remember**: Always deploy billing-alerts module first! 🛡️
