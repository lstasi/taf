# OCI Object Storage (Always Free) Documentation

**Current Phase**: Documentation

This document describes OCI Object Storage and how to use it within the always-free tier limits.

## 🎯 Always Free Limits

OCI Object Storage is part of the OCI **always-free tier** (not limited to 30-day trial):

- **20 GB** standard object storage (perpetually free)
- **10 GB** archive storage (perpetually free)
- **50,000 API requests/month** for Object Storage (read/write)
- **10 GB/month** outbound data transfer from Object Storage (part of 10 TB total egress)
- **No time limit**: These limits never expire

### Storage Classes
| Class | Free Limit | Use Case |
|-------|------------|----------|
| **Standard** | 20 GB | Frequently accessed data |
| **Infrequent Access** | N/A (charged) | Not in always-free tier |
| **Archive** | 10 GB | Long-term cold storage |

## ⚠️ What Causes Charges

You will incur charges if you:
- ❌ Store more than 20 GB in Standard storage
- ❌ Store more than 10 GB in Archive storage
- ❌ Use Infrequent Access storage class
- ❌ Exceed 50,000 API requests/month
- ❌ Use replication (Cross-Region Replication is paid)
- ❌ Enable Versioning with many object versions (adds to storage)
- ❌ Use Data Transfer accelerators (paid add-on)

## 🏗️ Use Cases Within Free Tier

### Standard Storage (20 GB) — Excellent For
- ✅ **Static website hosting**: HTML, CSS, JavaScript files
- ✅ **Application assets**: Images, videos, documents
- ✅ **Terraform state storage**: Remote state backend
- ✅ **Backup storage**: Config files, small database backups
- ✅ **Log archiving**: Compressed application logs
- ✅ **Data sharing**: Pre-authenticated request URLs for sharing
- ✅ **Container images**: Build artifacts and deployment packages
- ✅ **Machine learning datasets**: Training datasets under 20 GB

### Archive Storage (10 GB) — Excellent For
- ✅ **Long-term backups**: Infrequently accessed data
- ✅ **Compliance archives**: Audit logs and records
- ✅ **Historical data**: Old application data snapshots
- ✅ **Cold datasets**: ML training sets not currently in use

### Consider Alternatives For
- ⚠️ **Large datasets**: 20 GB standard + 10 GB archive limits
- ⚠️ **Frequent access to archive**: Archive requires restore time (hours)
- ⚠️ **Cross-region replication**: Not in always-free tier
- ⚠️ **High API call volumes**: 50,000/month limit on free tier

## 🎨 Architecture Patterns

### Pattern 1: Static Website Hosting
```
DNS (OCI DNS or external)
    ↓
Object Storage Bucket (public read, static files)
├── index.html
├── styles.css
├── app.js
└── assets/
```
**Use case**: Host static websites directly from Object Storage
**Cost**: Free within limits

### Pattern 2: Terraform Remote State
```
Terraform CLI
    ↓
OCI Object Storage Backend (state file)
    ↓
Terraform State (terraform.tfstate)
```
**Use case**: Centralized, shared Terraform state
**Cost**: Free within limits

### Pattern 3: Application File Storage
```
Application (OCI Compute)
    ↓
OCI Object Storage (20 GB standard)
├── uploads/  (user uploads)
├── reports/  (generated reports)
└── exports/  (data exports)
```
**Use case**: Application file storage backend
**Cost**: Free within limits

### Pattern 4: Log Archiving Pipeline
```
OCI Logging Service → Object Storage (standard, compressed)
    ↓ (after 30 days)
Object Storage Archive Tier (10 GB)
```
**Use case**: Log archiving with tiered storage
**Cost**: Free within limits

## 🔧 Configuration Best Practices

### Creating an Always-Free Bucket
```hcl
resource "oci_objectstorage_bucket" "free_bucket" {
  compartment_id = var.compartment_id
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = "my-always-free-bucket"
  access_type    = "NoPublicAccess"  # Private by default

  # Standard storage class (always free: 20 GB)
  storage_tier = "Standard"

  # Optional: Enable versioning (watch storage usage)
  versioning = "Disabled"  # Keep disabled to avoid extra storage

  freeform_tags = {
    FreeTier = "true"
    Purpose  = "app-storage"
  }
}

# Get the namespace (required for Object Storage operations)
data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.compartment_id
}
```

### Creating a Public Static Website Bucket
```hcl
resource "oci_objectstorage_bucket" "website_bucket" {
  compartment_id = var.compartment_id
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = "my-static-website"
  access_type    = "ObjectRead"  # Public read for static hosting

  storage_tier = "Standard"

  freeform_tags = {
    FreeTier = "true"
    Purpose  = "static-website"
  }
}
```

### Creating an Archive Bucket
```hcl
resource "oci_objectstorage_bucket" "archive_bucket" {
  compartment_id = var.compartment_id
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = "my-archive-storage"
  access_type    = "NoPublicAccess"

  # Archive storage class (always free: 10 GB)
  storage_tier = "Archive"

  freeform_tags = {
    FreeTier = "true"
    Purpose  = "cold-archive"
  }
}
```

### Terraform Remote State Backend
```hcl
# In your Terraform configuration
terraform {
  backend "http" {
    address        = "https://objectstorage.us-ashburn-1.oraclecloud.com/p/<pre-auth-token>/n/<namespace>/b/<bucket>/o/terraform.tfstate"
    update_method  = "PUT"
  }
}
```

### Pre-Authenticated Request (Temporary Access)
```hcl
resource "oci_objectstorage_preauthrequest" "temp_access" {
  namespace    = data.oci_objectstorage_namespace.ns.namespace
  bucket       = oci_objectstorage_bucket.free_bucket.name
  name         = "temp-read-access"
  access_type  = "ObjectRead"
  time_expires = timeadd(timestamp(), "24h")  # Expires in 24 hours
  object_name  = "shared-file.zip"
}

output "download_url" {
  value = oci_objectstorage_preauthrequest.temp_access.full_path
}
```

## 📊 Storage Management

### Monitoring Storage Usage

```hcl
# OCI Monitoring alarm for storage usage
resource "oci_monitoring_alarm" "storage_warning" {
  compartment_id        = var.compartment_id
  display_name          = "object-storage-usage-warning"
  destinations          = [oci_ons_notification_topic.alerts.id]
  is_enabled            = true
  metric_compartment_id = var.compartment_id
  namespace             = "oci_objectstorage"
  query                 = "StoredBytes[1d].mean() > 16106127360"  # 15 GB (75% of 20 GB)
  severity              = "WARNING"
}
```

### Storage Usage Thresholds
| Tier | Free Limit | Warning at | Action |
|------|-----------|------------|--------|
| Standard | 20 GB | 15 GB | Archive or delete |
| Archive | 10 GB | 8 GB | Delete or verify |

### Lifecycle Policies (Auto-Archive/Delete)
```hcl
resource "oci_objectstorage_object_lifecycle_policy" "cleanup" {
  namespace = data.oci_objectstorage_namespace.ns.namespace
  bucket    = oci_objectstorage_bucket.free_bucket.name

  rules {
    name            = "archive-old-logs"
    action          = "ARCHIVE"
    is_enabled      = true
    time_amount     = 30
    time_unit       = "DAYS"
    object_name_filter {
      inclusion_prefixes = ["logs/"]
    }
  }

  rules {
    name        = "delete-old-archives"
    action      = "DELETE"
    is_enabled  = true
    time_amount = 365
    time_unit   = "DAYS"
    object_name_filter {
      inclusion_prefixes = ["logs/"]
    }
  }
}
```

## 🔒 Security Best Practices

1. **Use private buckets by default**:
```hcl
access_type = "NoPublicAccess"  # Not "ObjectRead" or "ObjectReadWithoutList"
```

2. **Use IAM policies for fine-grained access**:
```
Allow group <AppGroup> to manage objects in compartment <CompartmentName>
  where target.bucket.name = '<BucketName>'
```

3. **Use Pre-Authenticated Requests** for temporary external access — not permanent public access

4. **Enable Server-Side Encryption** (enabled by default with Oracle-managed keys):
```hcl
# Oracle-managed encryption is default and free
# Customer-managed keys (Vault) available for higher security
```

5. **Enable Object Versioning** only when necessary — versions count toward storage

6. **Audit access** via OCI Audit logging (always free)

## 📈 Free Tier Monitoring

### OCI CLI Commands for Storage Inspection
```bash
# Get namespace
oci os ns get

# List buckets
oci os bucket list --compartment-id <compartment_ocid>

# Get bucket details (shows approximate size)
oci os bucket get --namespace-name <namespace> --bucket-name <bucket>

# List objects with sizes
oci os object list --namespace-name <namespace> --bucket-name <bucket>

# Get object storage usage (console preferred)
oci limits resource-availability get \
  --compartment-id <tenancy_ocid> \
  --service-name objectstorage \
  --limit-name total-storage-gb
```

## 🛡️ Staying Within Free Tier

1. **Monitor storage usage**: Check OCI Console → Object Storage → bucket → size
2. **Use lifecycle policies**: Auto-archive or delete old objects
3. **Compress before storing**: Gzip logs before uploading
4. **Track API calls**: 50,000/month limit
5. **Avoid versioning**: Each version counts toward storage limit
6. **Regularly audit**: Review buckets and delete unused objects
7. **Use billing-alerts**: Deploy the billing-alerts module first

## 🧪 Example Configurations

### Complete Static Website Setup
```hcl
# Bucket for static website
resource "oci_objectstorage_bucket" "website" {
  compartment_id = var.compartment_id
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = "my-website-${random_id.suffix.hex}"
  access_type    = "ObjectRead"
  storage_tier   = "Standard"
}

# Upload index.html
resource "oci_objectstorage_object" "index" {
  namespace    = data.oci_objectstorage_namespace.ns.namespace
  bucket       = oci_objectstorage_bucket.website.name
  object       = "index.html"
  source       = "${path.module}/website/index.html"
  content_type = "text/html"
}

output "website_url" {
  value = "https://objectstorage.${var.region}.oraclecloud.com/n/${data.oci_objectstorage_namespace.ns.namespace}/b/${oci_objectstorage_bucket.website.name}/o/index.html"
}
```

## 🔗 Related Resources

### OCI Documentation
- [Always Free Object Storage](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm)
- [Object Storage Overview](https://docs.oracle.com/en-us/iaas/Content/Object/home.htm)
- [Object Lifecycle Management](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/usinglifecyclepolicies.htm)
- [Pre-Authenticated Requests](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/usingpreauthenticatedrequests.htm)

### TAF Modules
- [billing-alerts](../billing-alerts/) - Monitor storage costs
- [compute](../compute/) - Compute that reads/writes to Object Storage
- [autonomous-db](../autonomous-db/) - Database with Object Storage integration
- [functions](../functions/) - Functions with Object Storage triggers

## 📝 Implementation Checklist

When deploying always-free Object Storage:

- [ ] Deploy billing-alerts module first
- [ ] Check current storage usage across all buckets
- [ ] Set appropriate access type (private by default)
- [ ] Enable lifecycle policies to manage storage growth
- [ ] Disable versioning unless needed (versions count toward storage)
- [ ] Set up OCI Monitoring alarms for storage usage (alert at 75%)
- [ ] Tag resources with FreeTier = "true"
- [ ] Test read/write access from your application
- [ ] Document bucket purposes and owners
- [ ] Monitor storage weekly

## 💡 Tips for Staying Free

1. **20 GB standard is enough** for most hobby projects
2. **Compress data before storing**: Gzip can reduce size by 70-80%
3. **Use lifecycle policies**: Auto-archive to save standard tier space
4. **Archive is great for backups**: 10 GB free for cold data
5. **Pre-auth URLs are free and temporary**: Great for sharing files
6. **Static website hosting is free**: No CDN cost for basic usage
7. **Monitor with OCI Console**: Built-in storage metrics are free

## 📞 Support

- [TAF Issues](https://github.com/lstasi/taf/issues)
- [OCI Support](https://www.oracle.com/support/)
- [OCI Object Storage Documentation](https://docs.oracle.com/en-us/iaas/Content/Object/home.htm)

---

**Remember**: Always deploy [billing-alerts](../billing-alerts/) first! 🛡️
