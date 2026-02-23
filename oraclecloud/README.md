# Oracle Cloud Always Free Resources

Documentation and (planned) Terraform modules for deploying Oracle Cloud **always-free** resources.

## 🎯 Focus: Always Free Only

This project focuses **exclusively on Oracle Cloud resources that are perpetually free** (not 30-day free trial offerings).

**Current Phase**: Documentation

Oracle Cloud offers several types of free resources:
- ✅ **Always Free**: Services that are perpetually free within certain limits (FOCUS OF THIS PROJECT)
- ❌ **30-Day Trial**: Free trial credits valid for 30 days from account creation (EXPLICITLY EXCLUDED)

## 📦 Always Free Resources (Documented)

### Billing & Monitoring
- **billing-alerts**: OCI Budgets and Notifications
  - Status: 📝 Documentation phase
  - Critical: Always deploy billing protection

### Compute (Always Free)
- **compute**: OCI Compute instances
  - AMD: 2× VM.Standard.E2.1.Micro (1/8 OCPU, 1 GB RAM each)
  - ARM: VM.Standard.A1.Flex up to 4 OCPUs and 24 GB RAM total
  - Status: 📝 Documentation phase

### Database (Always Free)
- **autonomous-db**: Oracle Autonomous Database
  - Limit: 2 databases, 1 OCPU and 20 GB storage each
  - Status: 📝 Documentation phase

### Storage (Always Free)
- **object-storage**: OCI Object Storage
  - Limit: 20 GB standard storage, 10 GB archive storage
  - Status: 📝 Documentation phase

### Serverless (Always Free)
- **functions**: Oracle Functions
  - Limit: 2M invocations/month, 400,000 GB-seconds/month
  - Status: 📝 Documentation phase

### Networking (Always Free)
- **networking**: OCI Virtual Cloud Network (VCN) and Load Balancer
  - Limit: VCN with subnets, 1 flexible load balancer (10 Mbps), 10 TB/month outbound data transfer
  - Status: 📝 Documentation phase

## ❌ Explicitly Excluded (30-Day Trial Only)

The following Oracle Cloud resources are **NOT included** in this project as they are only available during the free trial period:

- **Additional Compute shapes** (beyond E2.1.Micro and A1.Flex always-free limits)
- **Additional Autonomous Database instances** beyond the 2 always-free
- **Additional Object Storage** beyond the 20 GB always-free limit
- **Oracle Analytics Cloud** - Trial only
- **OCI Data Science** - Trial only

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
| **Compute AMD** | 2× VM.Standard.E2.1.Micro (1/8 OCPU, 1 GB RAM) | ✅ Yes | x86-based micro VMs |
| **Compute ARM** | VM.Standard.A1.Flex up to 4 OCPUs, 24 GB RAM | ✅ Yes | Arm-based, flexible sizing |
| **Autonomous DB** | 2 databases, 1 OCPU, 20 GB each | ✅ Yes | ATP or ADW |
| **Object Storage** | 20 GB standard, 10 GB archive | ✅ Yes | Standard storage class |
| **Block Volumes** | 2 volumes, 200 GB total, 5 volume backups | ✅ Yes | Boot/block volumes |
| **Functions** | 2M invocations/month, 400K GB-seconds | ✅ Yes | Serverless compute |
| **API Gateway** | 1M API calls/month | ✅ Yes | REST API management |
| **Networking** | 10 TB/month egress, 1 load balancer (10 Mbps) | ✅ Yes | VCN always free |
| **Monitoring** | 500M ingestion datapoints/month | ✅ Yes | Metrics and alarms |
| **Notifications** | 1M+ delivery/month | ✅ Yes | Email, HTTPS, Slack |
| **Logging** | 10 GB/month ingestion | ✅ Yes | Log data storage |
| **Vault** | 20 key versions, 150 secrets | ✅ Yes | Key management |
| **Certificates** | 5 certificates | ✅ Yes | TLS/SSL certificates |

### Why Oracle Cloud's Always-Free Tier Stands Out

Oracle Cloud's always-free tier is among the most generous in the industry:
- **Real compute**: Unlike other providers, Oracle offers actual ARM VMs with 4 OCPUs and 24 GB RAM permanently free
- **Real database**: Full Autonomous Database (ATP/ADW) with 1 OCPU and 20 GB perpetually free
- **Real networking**: 10 TB/month outbound data transfer (vs 1-15 GB for most competitors)
- **No credit card charges**: Resources stay free as long as you stay within limits

### Cost Warnings
Charges will occur if you:
- ❌ Exceed compute always-free shape limits (E2.1.Micro count or A1.Flex OCPU/RAM total)
- ❌ Create more than 2 Autonomous Database instances
- ❌ Store more than 20 GB in Object Storage (standard) or 10 GB (archive)
- ❌ Use more than 200 GB of Block Volume storage
- ❌ Use paid shapes (e.g., VM.Standard3.Flex, BM.* shapes)
- ❌ Enable additional paid services (Data Science, Analytics Cloud, etc.)
- ❌ Use GPU instances (always paid)

## 🛡️ Billing Protection Strategy

1. **Enable Budget Alerts**: Use the billing-alerts module
2. **Set Conservative Limits**: Set alerts well below actual free tier limits
3. **Monitor Monthly**: Check OCI Cost Management regularly
4. **Use Cost Analysis**: Review the OCI Cost Analysis dashboard
5. **Tag Resources**: Tag all resources for cost tracking
6. **Review Quotas**: Monitor service quotas to avoid accidental overages

## 📋 Prerequisites

### Required Tools
- Terraform >= 1.0.0
- OCI CLI configured
- Valid Oracle Cloud account (free tier)

### OCI Configuration

Configure OCI credentials using one of these methods:

**Option 1: OCI Configuration File**
```bash
oci setup config
```

This creates `~/.oci/config` with your tenancy OCID, user OCID, key file, fingerprint, and region.

**Option 2: Environment Variables**
```bash
export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..xxxxx"
export TF_VAR_user_ocid="ocid1.user.oc1..xxxxx"
export TF_VAR_fingerprint="aa:bb:cc:dd:..."
export TF_VAR_private_key_path="~/.oci/oci_api_key.pem"
export TF_VAR_region="us-ashburn-1"
```

**Option 3: Instance Principal (OCI Compute)**
- Assign dynamic groups and policies for OCI Compute instances
- No static credentials needed

**Option 4: Resource Principal (OCI Functions)**
- Used for Oracle Functions authentication
- No static credentials needed

### Required IAM Policies

Minimum permissions needed (adjust per module):
```
Allow group <GroupName> to manage all-resources in compartment <CompartmentName>
Allow group <GroupName> to read buckets in tenancy
Allow group <GroupName> to manage objects in tenancy
Allow group <GroupName> to manage autonomous-database-family in compartment <CompartmentName>
```

## 🔧 Module Usage Patterns

### Single Module
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

module "my_module" {
  source = "./oraclecloud/module-name"
  # ... module variables
}
```

### Multiple Modules
```hcl
# First: Billing protection
module "billing" {
  source = "./oraclecloud/billing-alerts"

  compartment_id    = var.compartment_id
  email_address     = "admin@example.com"
  monthly_threshold = 5.0
}

# Then: Resources
module "compute" {
  source = "./oraclecloud/compute"

  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  shape               = "VM.Standard.A1.Flex"
  ocpus               = 4
  memory_in_gbs       = 24
}

module "autonomous_db" {
  source = "./oraclecloud/autonomous-db"

  compartment_id = var.compartment_id
  db_name        = "MYFREEDB"
  db_workload    = "OLTP"  # ATP
}
```

## 🧪 Testing

Each module includes:
- Terraform validation
- Example configurations
- Security scanning (tfsec/checkov)

Run tests:
```bash
cd oraclecloud/module-name
terraform init
terraform validate
terraform plan
```

## 🔒 Security Best Practices

1. **Never commit credentials** - Use OCI configuration file or environment variables
2. **Use Instance Principals** - Prefer over API keys for compute-based automation
3. **Implement least privilege** - Minimal IAM policies per compartment
4. **Enable encryption** - All storage is encrypted by default (Oracle-managed keys)
5. **Use OCI Vault** - For secret management (20 key versions free)
6. **Compartment isolation** - Use compartments to isolate resources and policies
7. **Enable Audit Logging** - OCI Audit service is always free

## 📚 Additional Resources

- [OCI Free Tier Details](https://www.oracle.com/cloud/free/)
- [OCI Always Free Resources](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm)
- [OCI Cost Management](https://docs.oracle.com/en-us/iaas/Content/Billing/Concepts/costmanagementoverview.htm)
- [Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [OCI CLI Documentation](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)

## 🐛 Troubleshooting

### Common Issues

**Issue**: Always-free shape not available in selected region
- **Solution**: Use regions with always-free availability: US East (Ashburn), US West (Phoenix), Europe (Frankfurt), UK (London), etc.

**Issue**: Quota limit reached for always-free resources
- **Solution**: Check OCI Console → Limits, Quotas and Usage; ensure you haven't exceeded per-region limits

**Issue**: Authentication errors with Terraform provider
- **Solution**: Verify `~/.oci/config` is correct; check fingerprint matches the uploaded API key

**Issue**: Autonomous Database free tier limit
- **Solution**: Only 2 always-free Autonomous Databases per tenancy; check existing instances

**Issue**: A1.Flex capacity not available
- **Solution**: ARM instances may have limited capacity; try different availability domains or regions

## 📞 Support

- GitHub Issues: [Report bugs or request features](https://github.com/lstasi/taf/issues)
- OCI Support: For Oracle Cloud-specific questions
- OCI Documentation: [Official OCI Docs](https://docs.oracle.com/en-us/iaas/)

## 🗺️ Roadmap

See [TODO.md](../TODO.md) for detailed implementation status.

---

**Remember**: Always deploy billing-alerts module first! 🛡️
