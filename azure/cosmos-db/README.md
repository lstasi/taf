# Azure Cosmos DB (Always Free) Documentation

**Current Phase**: Documentation

This document describes Azure Cosmos DB and how to use it within the always-free tier limits.

## 🎯 Always Free Limits

Azure Cosmos DB offers an **always-free tier** (not limited to 12 months):

- **1,000 RU/s provisioned throughput** (perpetually free)
- **25GB storage** (perpetually free)
- **One free tier account per Azure subscription**
- **No time limit**: These limits never expire

### What are Request Units (RU/s)?

Request Units (RU) measure the throughput cost of database operations:
- **1 RU** = Cost of reading a 1KB document by its ID
- **RU/s** = Request Units per second (throughput)
- **1,000 RU/s** allows approximately:
  - 1,000 point reads per second (1KB documents)
  - 100-200 writes per second (depending on document size)
  - 10-50 queries per second (depending on complexity)

### Practical Examples

**Example 1: Simple Read-Heavy App**
- Point reads: 500 RU/s average
- Writes: 200 RU/s average
- Queries: 200 RU/s average
- **Total**: 900 RU/s ✅ Within free tier

**Example 2: Balanced App**
- Point reads: 300 RU/s average
- Writes: 400 RU/s average
- Queries: 250 RU/s average
- **Total**: 950 RU/s ✅ Within free tier

**Example 3: Query-Heavy App**
- Point reads: 100 RU/s average
- Writes: 100 RU/s average
- Complex queries: 700 RU/s average
- **Total**: 900 RU/s ✅ Within free tier

## ⚠️ What Causes Charges

You will incur charges if:
- ❌ Exceed 1,000 RU/s provisioned throughput
- ❌ Exceed 25GB storage
- ❌ Create more than one free tier account per subscription
- ❌ Use autoscale (always costs, even at minimum)
- ❌ Use multi-region writes (additional cost)
- ❌ Use dedicated gateway (always costs)
- ❌ High bandwidth egress beyond free limits

## 🏗️ Use Cases Within Free Tier

### Excellent Use Cases
- ✅ **User profiles**: Store user data for small apps
- ✅ **Session data**: Session storage for web apps
- ✅ **Metadata stores**: Document metadata, configs
- ✅ **IoT data**: Device readings (with aggregation)
- ✅ **Chat history**: Message storage for small apps
- ✅ **Catalog data**: Product catalogs, content
- ✅ **Game state**: Player profiles, game saves
- ✅ **Serverless backends**: CRUD with Azure Functions

### Consider Alternatives For
- ⚠️ **High throughput apps**: >1,000 RU/s needs
- ⚠️ **Large datasets**: >25GB storage needs
- ⚠️ **Multi-region**: Global distribution (costly)
- ⚠️ **Complex analytics**: Consider dedicated analytics DB
- ⚠️ **High write volumes**: Watch RU consumption

## 🎨 Architecture Patterns

### Pattern 1: Azure Functions + Cosmos DB
```
HTTP Trigger (1M requests/month)
    ↓
Azure Function (processes request)
    ↓
Cosmos DB (1,000 RU/s, 25GB free)
```

**Use case**: REST API backend
**Cost**: Free within limits

### Pattern 2: Event-Driven Processing
```
Event Grid (100K operations/month)
    ↓
Azure Function (processes event)
    ↓
Cosmos DB (stores results)
```

**Use case**: Real-time data processing
**Cost**: Free within limits

### Pattern 3: Change Feed Pattern
```
Cosmos DB (change feed)
    ↓
Azure Function (triggered by change)
    ↓
Notification Hub (sends alert)
```

**Use case**: Real-time notifications
**Cost**: Free within limits

## 📊 Partitioning Strategies

### Choosing a Partition Key

The partition key is **critical** for performance and cost:

| Pattern | Partition Key | Use Case |
|---------|---------------|----------|
| **User data** | `/userId` | User-specific queries |
| **Tenant data** | `/tenantId` | Multi-tenant apps |
| **Time series** | `/deviceId` | IoT data |
| **Geographic** | `/region` | Location-based data |
| **Category** | `/category` | Catalog/content |

### Best Practices

1. **High cardinality**: Many unique values
2. **Even distribution**: Balance across partitions
3. **Query affinity**: Most queries use partition key
4. **Write distribution**: Avoid hot partitions
5. **Size limits**: 20GB per logical partition

### Anti-patterns to Avoid

- ❌ **Low cardinality keys**: E.g., status (active/inactive)
- ❌ **Sequential keys**: E.g., auto-increment IDs
- ❌ **Timestamp only**: Creates hot partitions
- ❌ **Random GUIDs**: Poor query performance

## 🔧 Configuration Best Practices

### Database Configuration

```hcl
resource "azurerm_cosmosdb_account" "main" {
  name                = "my-cosmos-account"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  
  # Enable free tier (only one per subscription!)
  free_tier_enabled = true

  consistency_policy {
    consistency_level = "Session"  # Best for most apps
  }

  geo_location {
    location          = azurerm_resource_group.main.location
    failover_priority = 0
  }

  # Disable features that cost extra
  enable_automatic_failover = false
  enable_multiple_write_locations = false
  
  tags = {
    FreeTier = "true"
  }
}
```

### Container Configuration

```hcl
resource "azurerm_cosmosdb_sql_container" "main" {
  name                = "my-container"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_sql_database.main.name
  
  partition_key_paths = ["/userId"]
  
  # Use provisioned throughput at database level
  # to share 1,000 RU/s across containers
}

resource "azurerm_cosmosdb_sql_database" "main" {
  name                = "my-database"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
  
  # Set throughput at database level (shared)
  throughput = 1000  # Max free tier
}
```

### Consistency Levels

Choose wisely - affects both performance and cost:

| Level | RU Cost | Consistency | Use Case |
|-------|---------|-------------|----------|
| **Strong** | Higher | Highest | Financial data |
| **Bounded Staleness** | Medium-High | High | Global apps |
| **Session** | Medium | Good | Most applications |
| **Consistent Prefix** | Lower | Moderate | Analytics |
| **Eventual** | Lowest | Basic | High throughput needs |

**Recommendation**: Use **Session** consistency for most apps (best balance).

## 📈 Free Tier Monitoring

### Track RU Consumption

```hcl
resource "azurerm_monitor_metric_alert" "cosmos_ru" {
  name                = "cosmos-high-ru-usage"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_cosmosdb_account.main.id]
  description         = "Alert when RU consumption exceeds 80%"

  criteria {
    metric_namespace = "Microsoft.DocumentDB/databaseAccounts"
    metric_name      = "NormalizedRUConsumption"
    aggregation      = "Maximum"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.billing.id
  }
}
```

### Track Storage Usage

```hcl
resource "azurerm_monitor_metric_alert" "cosmos_storage" {
  name                = "cosmos-high-storage"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_cosmosdb_account.main.id]
  description         = "Alert when storage exceeds 80% of free tier"

  criteria {
    metric_namespace = "Microsoft.DocumentDB/databaseAccounts"
    metric_name      = "DataUsage"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 21474836480  # 20GB (80% of 25GB)
  }

  action {
    action_group_id = azurerm_monitor_action_group.billing.id
  }
}
```

### Key Metrics to Monitor

- **NormalizedRUConsumption**: % of provisioned RU/s used
- **TotalRequests**: Number of requests
- **DataUsage**: Storage used in bytes
- **DocumentCount**: Number of documents
- **ProvisionedThroughput**: Current RU/s setting
- **ThrottledRequests**: Requests exceeding throughput (429 errors)

## 🛡️ Staying Within Free Tier

### Strategies

1. **Optimize queries**:
   - Use partition keys in queries
   - Avoid cross-partition queries
   - Use projections to return only needed fields
   - Index only needed properties

2. **Efficient data modeling**:
   - Denormalize when possible
   - Use embedded documents
   - Avoid unnecessary nesting
   - Keep documents small

3. **Caching**:
   - Cache frequently read data
   - Use application-level caching
   - Consider in-memory caching libraries

4. **Batch operations**:
   - Use bulk operations
   - Batch writes when possible
   - Use transactional batch for related items

5. **Monitoring**:
   - Set alerts at 80% of limits
   - Review metrics daily
   - Use billing alerts

### Query Optimization Tips

```javascript
// Good: Uses partition key
SELECT * FROM c WHERE c.userId = 'user123'  // ~1 RU

// Better: Returns only needed fields
SELECT c.name, c.email FROM c WHERE c.userId = 'user123'  // <1 RU

// Avoid: Cross-partition query
SELECT * FROM c WHERE c.email = 'user@example.com'  // Many RUs

// Avoid: Scanning all documents
SELECT * FROM c  // Very expensive
```

## 🧪 Example Configurations

### Complete Free Tier Setup

```hcl
# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "cosmos-free-tier-rg"
  location = "eastus"
}

# Cosmos DB Account with Free Tier
resource "azurerm_cosmosdb_account" "main" {
  name                = "mycosmosaccount${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  
  # CRITICAL: Enable free tier
  free_tier_enabled = true

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.main.location
    failover_priority = 0
  }

  tags = {
    FreeTier    = "true"
    Environment = "production"
  }
}

# Database with shared throughput
resource "azurerm_cosmosdb_sql_database" "main" {
  name                = "app-database"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
  throughput          = 1000  # Shared across containers
}

# Users Container
resource "azurerm_cosmosdb_sql_container" "users" {
  name                = "users"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_sql_database.main.name
  partition_key_paths = ["/userId"]

  indexing_policy {
    indexing_mode = "consistent"
    
    included_path {
      path = "/email/*"
    }
    
    excluded_path {
      path = "/*"  # Exclude all other paths
    }
  }
}

# Products Container
resource "azurerm_cosmosdb_sql_container" "products" {
  name                = "products"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_sql_database.main.name
  partition_key_paths = ["/category"]

  indexing_policy {
    indexing_mode = "consistent"
    
    included_path {
      path = "/name/*"
    }
    
    included_path {
      path = "/price/*"
    }
    
    excluded_path {
      path = "/*"
    }
  }
}

# Random suffix for globally unique name
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Output connection string
output "connection_string" {
  value     = azurerm_cosmosdb_account.main.primary_sql_connection_string
  sensitive = true
}
```

### Cosmos DB with Azure Functions

```hcl
# Function App that uses Cosmos DB
resource "azurerm_linux_function_app" "api" {
  name                = "cosmos-api-function"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  storage_account_name       = azurerm_storage_account.main.name
  storage_account_access_key = azurerm_storage_account.main.primary_access_key
  service_plan_id            = azurerm_service_plan.main.id

  site_config {
    application_stack {
      node_version = "18"
    }
  }

  app_settings = {
    "COSMOS_ENDPOINT" = azurerm_cosmosdb_account.main.endpoint
    "COSMOS_KEY"      = azurerm_cosmosdb_account.main.primary_key
    "COSMOS_DATABASE" = azurerm_cosmosdb_sql_database.main.name
  }
}
```

## 🔒 Security Best Practices

1. **Use Managed Identity**:
   ```hcl
   # Assign RBAC role instead of connection strings
   resource "azurerm_cosmosdb_sql_role_assignment" "function" {
     resource_group_name = azurerm_resource_group.main.name
     account_name        = azurerm_cosmosdb_account.main.name
     role_definition_id  = "${azurerm_cosmosdb_account.main.id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
     principal_id        = azurerm_linux_function_app.api.identity[0].principal_id
     scope               = azurerm_cosmosdb_account.main.id
   }
   ```

2. **Network security**:
   - Use private endpoints (may incur charges)
   - Configure firewall rules
   - Limit IP access

3. **Encryption**:
   - Data encrypted at rest (default)
   - Use HTTPS for all connections
   - Consider customer-managed keys (costs extra)

4. **Access control**:
   - Use RBAC over access keys
   - Rotate keys regularly
   - Audit access logs

## 🐛 Troubleshooting

### Issue: 429 Too Many Requests

**Symptoms**: Throttling errors, requests failing

**Solutions**:
1. Check NormalizedRUConsumption metric
2. Optimize queries to use less RU
3. Implement retry with exponential backoff
4. Distribute operations over time
5. Consider query patterns

### Issue: Exceeding Storage Limit

**Symptoms**: Approaching 25GB limit, write failures

**Solutions**:
1. Archive old data
2. Implement TTL (Time to Live) on documents
3. Compress data where possible
4. Clean up unused containers
5. Monitor DataUsage metric

### Issue: Slow Queries

**Symptoms**: High RU consumption, slow response

**Solutions**:
1. Add partition key to queries
2. Review indexing policy
3. Use projections to limit returned fields
4. Avoid cross-partition queries
5. Profile queries in Data Explorer

### Issue: Free Tier Not Applied

**Symptoms**: Charges on free tier account

**Solutions**:
1. Verify `free_tier_enabled = true`
2. Check only one free tier per subscription
3. Verify not using autoscale
4. Review multi-region settings

## 🔗 Related Resources

### Azure Documentation
- [Cosmos DB Pricing](https://azure.microsoft.com/pricing/details/cosmos-db/)
- [Free Tier Guide](https://docs.microsoft.com/azure/cosmos-db/free-tier)
- [Request Units](https://docs.microsoft.com/azure/cosmos-db/request-units)
- [Partitioning](https://docs.microsoft.com/azure/cosmos-db/partitioning-overview)

### TAF Modules
- [billing-alerts](../billing-alerts/) - Monitor Cosmos DB costs
- [functions](../functions/) - Azure Functions with Cosmos DB
- [event-grid](../event-grid/) - Event triggers
- [service-bus](../service-bus/) - Queue integration

### Tools
- [Cosmos DB Emulator](https://docs.microsoft.com/azure/cosmos-db/local-emulator)
- [Data Explorer](https://cosmos.azure.com/)
- [Terraform Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account)

## 📝 Implementation Checklist

When implementing Cosmos DB:

- [ ] Deploy billing-alerts module first
- [ ] Enable free tier on account (`free_tier_enabled = true`)
- [ ] Verify only one free tier account per subscription
- [ ] Choose appropriate partition key
- [ ] Set throughput at database level (shared)
- [ ] Configure indexing policy for your queries
- [ ] Use Session consistency unless required otherwise
- [ ] Set up monitoring alerts for RU and storage
- [ ] Test queries in Data Explorer first
- [ ] Monitor usage for first week
- [ ] Optimize based on actual metrics
- [ ] Document container schema and indexes
- [ ] Tag resources for cost tracking

## 💡 Tips for Staying Free

1. **Use free tier account**: Only one per subscription
2. **Share throughput**: Use database-level throughput
3. **Optimize queries**: Use partition keys, projections
4. **Monitor actively**: Check metrics daily
5. **Use TTL**: Auto-delete old documents
6. **Custom indexing**: Index only what you query
7. **Batch writes**: Reduce individual operations
8. **Cache reads**: Use application-level caching

## 📞 Support

- [TAF Issues](https://github.com/lstasi/taf/issues)
- [Azure Support](https://azure.microsoft.com/support/)
- [Cosmos DB Forum](https://docs.microsoft.com/answers/topics/azure-cosmos-db.html)

---

**Remember**: Always deploy [billing-alerts](../billing-alerts/) first! 🛡️
