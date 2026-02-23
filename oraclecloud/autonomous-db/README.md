# Oracle Autonomous Database (Always Free) Documentation

**Current Phase**: Documentation

This document describes Oracle Autonomous Database and how to use it within the always-free tier limits.

## 🎯 Always Free Limits

Oracle Autonomous Database is part of the OCI **always-free tier** (not limited to 30-day trial):

- **2 Autonomous Databases** per tenancy (perpetually free)
- **1 OCPU** per database
- **20 GB storage** per database
- **No time limit**: These limits never expire
- **Auto-scaling is disabled** in the always-free tier

### Database Workload Types (Both Always Free)
- **ATP (Autonomous Transaction Processing)**: OLTP workloads, JSON, REST APIs
- **ADW (Autonomous Data Warehouse)**: Analytics, data warehousing, batch queries
- **AJD (Autonomous JSON Database)**: JSON document store, MongoDB-compatible API
- **APEX Service**: Oracle APEX low-code application platform

## ⚠️ What Causes Charges

You will incur charges if you:
- ❌ Create more than 2 Autonomous Database instances
- ❌ Enable auto-scaling (scales beyond always-free OCPU/storage limits)
- ❌ Use dedicated Exadata infrastructure
- ❌ Store more than 20 GB per database
- ❌ Enable backup storage beyond included amount
- ❌ Use more than 1 OCPU (unless on shared infrastructure within limits)

## 🏗️ Use Cases Within Free Tier

### ATP (Autonomous Transaction Processing) — Excellent For
- ✅ **Web application backends**: Persistent data for REST APIs
- ✅ **User management**: Authentication and profile storage
- ✅ **Session management**: Application session state
- ✅ **Transactional data**: Orders, events, logs
- ✅ **Oracle APEX applications**: Low-code web apps via APEX Service
- ✅ **JSON document storage**: Schema-flexible document data
- ✅ **REST-enabled tables**: Automatic REST API generation (ORDS)

### ADW (Autonomous Data Warehouse) — Excellent For
- ✅ **Analytics queries**: Complex aggregation and reporting
- ✅ **Data exploration**: Ad-hoc analysis of datasets
- ✅ **ETL target**: Load and transform data for analysis
- ✅ **Business intelligence**: BI tool backend (up to 20 GB)
- ✅ **Learning SQL analytics**: Window functions, ML in-database

### AJD (Autonomous JSON Database) — Excellent For
- ✅ **JSON document storage**: Native JSON with SQL access
- ✅ **MongoDB-compatible**: Use MongoDB drivers against Oracle
- ✅ **Hybrid workloads**: Mix relational and document models
- ✅ **Mobile app backends**: Flexible schema for rapid development

### Consider Alternatives For
- ⚠️ **Large datasets**: 20 GB limit per database
- ⚠️ **High-throughput OLTP**: 1 OCPU limits concurrent transactions
- ⚠️ **Multi-region replication**: Not available in always-free tier
- ⚠️ **Data Guard/HA**: Standby databases are not in free tier

## 🎨 Architecture Patterns

### Pattern 1: Web API + ATP
```
Client
    ↓
OCI API Gateway (1M calls/month free)
    ↓
Oracle Functions (2M invocations free) OR Compute (A1.Flex free)
    ↓
Autonomous Transaction Processing (1 OCPU, 20 GB free)
```
**Use case**: REST API with Oracle DB backend
**Cost**: Free within limits

### Pattern 2: APEX Low-Code Application
```
Browser
    ↓
Oracle APEX Service (ATP free tier)
    ↓
Built-in APEX application server
    ↓
ATP Database (1 OCPU, 20 GB)
```
**Use case**: No-code/low-code web application
**Cost**: Free within limits (APEX is included with ATP)

### Pattern 3: Analytics Platform
```
Data Sources (APIs, CSV files)
    ↓
OCI Object Storage (20 GB free)
    ↓
Autonomous Data Warehouse (1 OCPU, 20 GB)
    ↓
Reporting Tool / Oracle Analytics (connection only)
```
**Use case**: Personal analytics and reporting
**Cost**: Free within limits

### Pattern 4: JSON Application (MongoDB-compatible)
```
Application (using MongoDB driver)
    ↓
Autonomous JSON Database (1 OCPU, 20 GB)
    ↓ (also supports SQL)
SQL Analytics / Reports
```
**Use case**: Document-oriented application with SQL analytics
**Cost**: Free within limits

## 🔧 Configuration Best Practices

### Creating an Always-Free ATP Instance
```hcl
resource "oci_database_autonomous_database" "free_atp" {
  compartment_id           = var.compartment_id
  db_name                  = "FREEATP"
  display_name             = "free-atp-database"
  db_workload              = "OLTP"  # ATP
  is_free_tier             = true    # IMPORTANT: Enable always-free
  cpu_core_count           = 1
  data_storage_size_in_tbs = 0       # 0.02 TB = 20 GB for free tier
  admin_password           = var.admin_password  # Min 12 chars, must contain uppercase, number, special

  # Always-free requires serverless infrastructure
  is_dedicated            = false

  freeform_tags = {
    FreeTier = "true"
    Purpose  = "web-backend"
  }
}
```

### Creating an Always-Free ADW Instance
```hcl
resource "oci_database_autonomous_database" "free_adw" {
  compartment_id           = var.compartment_id
  db_name                  = "FREEADW"
  display_name             = "free-adw-database"
  db_workload              = "DW"    # ADW
  is_free_tier             = true    # IMPORTANT: Enable always-free
  cpu_core_count           = 1
  data_storage_size_in_tbs = 0       # 20 GB for free tier

  is_dedicated = false

  freeform_tags = {
    FreeTier = "true"
    Purpose  = "analytics"
  }
}
```

### Connecting Applications

**Wallet-based connection (recommended for external apps)**:
```hcl
# Download the connection wallet
resource "oci_database_autonomous_database_wallet" "wallet" {
  autonomous_database_id = oci_database_autonomous_database.free_atp.id
  password               = var.wallet_password
  generate_type          = "SINGLE"  # For a single instance connection
}
```

**JDBC connection string**:
```
jdbc:oracle:thin:@(description=(retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=<host>))(connect_data=(service_name=<service>))(security=(ssl_server_dn_match=yes)))
```

## 📊 Database Capabilities (Always Free)

### Features Included in Always-Free ATP/ADW
| Feature | Available | Notes |
|---------|-----------|-------|
| **Oracle SQL** | ✅ | Full SQL support |
| **Oracle APEX** | ✅ | Low-code app platform |
| **Oracle REST Data Services (ORDS)** | ✅ | Auto REST APIs |
| **JSON Support** | ✅ | Native JSON data type |
| **PL/SQL** | ✅ | Procedural SQL |
| **Oracle Machine Learning (OML)** | ✅ | In-database ML |
| **Oracle Spatial** | ✅ | Geospatial data |
| **Oracle Graph** | ✅ | Graph analytics |
| **Automatic Indexing** | ✅ | AI-driven index optimization |
| **Automatic Backup** | ✅ | 60-day backup retention |
| **Oracle Analytics Cloud** | ❌ | Separate paid service |
| **Dedicated Exadata** | ❌ | Paid tier only |
| **Cross-Region Data Guard** | ❌ | Paid tier only |

## 📈 Free Tier Monitoring

### OCI Metrics for Autonomous Database
Monitor via OCI Monitoring (always free):

```hcl
# Example: Storage usage alarm (warn at 80% of 20 GB = 16 GB)
resource "oci_monitoring_alarm" "db_storage_warning" {
  compartment_id        = var.compartment_id
  display_name          = "atp-storage-warning"
  destinations          = [oci_ons_notification_topic.alerts.id]
  is_enabled            = true
  metric_compartment_id = var.compartment_id
  namespace             = "oci_autonomous_database"
  query                 = "StorageUtilization[1h].mean() > 80"
  severity              = "WARNING"
}

# Example: CPU usage alarm
resource "oci_monitoring_alarm" "db_cpu_warning" {
  compartment_id        = var.compartment_id
  display_name          = "atp-cpu-warning"
  destinations          = [oci_ons_notification_topic.alerts.id]
  is_enabled            = true
  metric_compartment_id = var.compartment_id
  namespace             = "oci_autonomous_database"
  query                 = "CpuUtilization[5m].mean() > 80"
  severity              = "WARNING"
}
```

### Key Metrics to Watch
- `StorageUtilization` — Percentage of 20 GB used
- `CpuUtilization` — OCPU usage (keep under 100% on average)
- `CurrentLogons` — Active connections
- `UserTransactionPerSec` — Transaction rate
- `ParseCount` — SQL parse activity

## 🛡️ Staying Within Free Tier

1. **Set `is_free_tier = true`**: Always set this flag to prevent accidental paid tier
2. **Monitor storage**: Keep well under 20 GB (set alarm at 80%)
3. **Disable auto-scaling**: Auto-scaling is disabled by default on free tier, keep it off
4. **Use connection pooling**: Minimize connections to stay within 1 OCPU capacity
5. **Optimize queries**: Use APEX Performance Hub for query analysis
6. **Purge old data**: Regularly clean up old data to stay within 20 GB
7. **Use billing-alerts**: Deploy the billing-alerts module first

## 🔒 Security Best Practices

1. **Never store the admin password in Terraform state**:
```hcl
# Use a variable with sensitive = true
variable "admin_password" {
  type      = string
  sensitive = true
}

# Or use OCI Vault to retrieve the password
data "oci_secrets_secretbundle" "db_password" {
  secret_id = var.db_password_secret_id
}
```

2. **Enable network access restrictions**:
```hcl
resource "oci_database_autonomous_database" "free_atp" {
  # ...

  # Restrict to specific IPs or VCN
  whitelisted_ips = ["YOUR_IP/32"]

  # Or use private endpoint for VCN-only access
  # private_endpoint_label = "myatp"
  # subnet_id              = var.private_subnet_id
}
```

3. **Use wallets for external connections** — Enforces mTLS encryption
4. **Rotate admin password** regularly
5. **Create app-specific DB users** — Never use ADMIN for applications
6. **Enable Data Safe** for security assessment (free for Autonomous DB)

## 🐛 Troubleshooting

### Issue: Free Tier Not Available

**Symptoms**: Error "Free tier is not available" when creating

**Solutions**:
1. Check if you already have 2 Autonomous Databases
2. Try a different OCI region (free tier is per-tenancy, not per-region)
3. Verify your tenancy is on the always-free plan

### Issue: Storage Approaching Limit

**Symptoms**: `StorageUtilization` metric > 80%

**Solutions**:
1. Query to find largest tables: `SELECT * FROM dba_segments ORDER BY bytes DESC`
2. Purge old records or archive to Object Storage
3. Compress tables where possible
4. Drop unused indexes (Automatic Indexing can recreate them)

### Issue: High CPU Usage (1 OCPU)

**Symptoms**: Slow queries, connection timeouts

**Solutions**:
1. Review top SQL using APEX Performance Hub (free)
2. Add indexes to slow queries
3. Use result caching for repeated queries
4. Implement application-level caching
5. Use connection pooling to avoid connection overhead

### Issue: Connection Errors

**Symptoms**: Application cannot connect to database

**Solutions**:
1. Verify wallet is downloaded and paths are correct
2. Check TNS_ADMIN environment variable points to wallet directory
3. Verify ACL rules / whitelisted IPs allow your source IP
4. Ensure the database state is `AVAILABLE` (not `STOPPED`)

### Issue: Database Stopped Automatically

**Symptoms**: Database stopped after period of inactivity

**Solutions**:
1. Always-free databases stop after 7 days of inactivity
2. Restart via OCI Console: Autonomous Database → More Actions → Start
3. Schedule a lightweight ping job to keep it active

## 🔗 Related Resources

### OCI Documentation
- [Always Free Autonomous Database](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm)
- [Autonomous Database Overview](https://docs.oracle.com/en-us/iaas/Content/Database/Concepts/adboverview.htm)
- [Oracle APEX](https://apex.oracle.com/)
- [Oracle REST Data Services](https://www.oracle.com/database/technologies/appdev/rest.html)

### TAF Modules
- [billing-alerts](../billing-alerts/) - Monitor database costs
- [compute](../compute/) - Compute instances to connect to database
- [networking](../networking/) - VCN for private database access
- [functions](../functions/) - Serverless functions with database access

## 📝 Implementation Checklist

When deploying always-free Autonomous Databases:

- [ ] Deploy billing-alerts module first
- [ ] Count existing Autonomous Databases (max 2 per tenancy)
- [ ] Set `is_free_tier = true` on the resource
- [ ] Store admin password securely (use OCI Vault or Terraform sensitive variables)
- [ ] Download and configure the connection wallet
- [ ] Create application-specific database users (not ADMIN)
- [ ] Enable OCI Monitoring alarms for storage and CPU
- [ ] Set up automatic backups (enabled by default, 60 days)
- [ ] Test connectivity from your application
- [ ] Enable APEX if needed (go to ATP → Tools → Oracle APEX)
- [ ] Tag resources with FreeTier = "true"
- [ ] Monitor storage usage weekly

## 💡 Tips for Staying Free

1. **Set `is_free_tier = true`**: Critical — prevents upgrading to paid
2. **Keep 2 databases in total**: Free per tenancy, across all regions
3. **Use APEX for web apps**: Full low-code platform included free
4. **Use ORDS for REST APIs**: Auto-generates REST endpoints from tables
5. **Archive to Object Storage**: Move old data to keep under 20 GB
6. **Always-free stops after 7 days idle**: Keep active or automate restarts
7. **Use OML for ML**: In-database machine learning at no extra cost

## 📞 Support

- [TAF Issues](https://github.com/lstasi/taf/issues)
- [OCI Support](https://www.oracle.com/support/)
- [Oracle Database Community](https://community.oracle.com/tech/developers/categories/oracle-database)
- [Oracle APEX Community](https://apex.oracle.com/community)

---

**Remember**: Always deploy [billing-alerts](../billing-alerts/) first! 🛡️
