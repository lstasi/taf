# Azure Functions (Always Free) Documentation

**Current Phase**: Documentation

This document describes Azure Functions and how to use it within the always-free tier limits.

## 🎯 Always Free Limits

Azure Functions is part of the Azure **always-free tier** (not limited to 12 months):

- **1 Million executions** per month (perpetually free)
- **400,000 GB-seconds** of resource consumption per month (perpetually free)
- **Consumption Plan only**: Free tier applies only to Consumption pricing plan
- **No time limit**: These limits never expire

### What are GB-seconds?

GB-seconds is a measure of function execution time multiplied by memory consumption:
- **1 GB-second** = 1 function running for 1 second consuming 1GB memory
- **400,000 GB-seconds** examples:
  - 400,000 executions × 1 second × 1GB memory
  - 800,000 executions × 0.5 seconds × 1GB memory
  - 3,200,000 executions × 0.125 seconds × 1GB memory

### Practical Examples

**Example 1: Simple HTTP API (128MB)**
- Memory: 128MB (0.125GB)
- Duration: 100ms (0.1 seconds)
- Monthly executions: 1M (free tier limit)
- GB-seconds used: 1M × 0.1 × 0.125 = 12,500 GB-seconds
- **Result**: Well within free tier ✅

**Example 2: Data Processing (512MB)**
- Memory: 512MB (0.5GB)
- Duration: 500ms (0.5 seconds)
- Monthly executions: 100,000
- GB-seconds used: 100K × 0.5 × 0.5 = 25,000 GB-seconds
- **Result**: Well within free tier ✅

**Example 3: Heavy Processing (1.5GB)**
- Memory: 1536MB (1.5GB)
- Duration: 1 second
- Monthly executions: 200,000
- GB-seconds used: 200K × 1 × 1.5 = 300,000 GB-seconds
- **Result**: Within free tier ✅

## ⚠️ What Causes Charges

You will incur charges if:
- ❌ Exceed 1M executions/month
- ❌ Exceed 400,000 GB-seconds/month
- ❌ Use Premium or Dedicated (App Service) plans
- ❌ Use Durable Functions extensively (storage charges)
- ❌ High bandwidth egress (5GB/month free)
- ❌ Use Always-On feature (requires App Service plan)
- ❌ Use VNet integration (requires Premium or higher)

## 🏗️ Use Cases Within Free Tier

### Excellent Use Cases
- ✅ **HTTP APIs**: REST endpoints with HTTP triggers
- ✅ **Scheduled tasks**: Timer triggers for cron jobs
- ✅ **Webhooks**: GitHub, Azure DevOps, Stripe integrations
- ✅ **Event processing**: Event Grid and Event Hub triggers
- ✅ **Queue processing**: Service Bus and Storage Queue triggers
- ✅ **Serverless backends**: CRUD operations for apps
- ✅ **Automation**: Azure resource management tasks
- ✅ **Data transformations**: ETL with Cosmos DB

### Consider Alternatives For
- ⚠️ **Long-running jobs**: >10 minute execution (Consumption plan limit)
- ⚠️ **High-frequency polling**: Consider Event Grid or Service Bus
- ⚠️ **Large data transfers**: Watch bandwidth limits
- ⚠️ **Stateful applications**: Use Durable Functions carefully
- ⚠️ **Very high traffic**: Monitor execution counts closely

## 🎨 Architecture Patterns

### Pattern 1: HTTP API + Cosmos DB
```
HTTP Trigger (1M requests/month)
    ↓
Azure Function (processes request)
    ↓
Cosmos DB (1,000 RU/s, 25GB free)
```

**Use case**: REST API for web/mobile app
**Cost**: Free within limits

### Pattern 2: Timer + Azure Services
```
Timer Trigger (scheduled)
    ↓
Azure Function (processes data)
    ↓
Notification Hub (sends alerts)
```

**Use case**: Daily report generation
**Cost**: Free within limits

### Pattern 3: Event Grid + Function
```
Event Grid (100K operations/month)
    ↓
Azure Function (processes event)
    ↓
Service Bus (queues result)
```

**Use case**: Event-driven processing
**Cost**: Free within limits

### Pattern 4: Queue Processing
```
Service Bus Queue (750 hours/month)
    ↓
Azure Function (processes messages)
    ↓
Cosmos DB (stores results)
```

**Use case**: Async job processing
**Cost**: Free within limits

## 📊 Memory and Duration Optimization

### Memory Configuration

Functions charge based on memory consumed during execution:

| Memory | Price per GB-sec | When to Use |
|--------|------------------|-------------|
| **128MB** | Cheapest | Simple APIs, webhooks |
| **256MB** | Low cost | JSON processing, light work |
| **512MB** | Moderate | API calls, data processing |
| **1024MB** | Balanced | Database queries, computations |
| **1536MB+** | Higher cost | CPU-intensive, large data |

**Tip**: Azure dynamically allocates memory, but you can set minimum in some cases.

### Duration Optimization Tips

1. **Cold starts**: First invocation is slower
   - Keep function code minimal
   - Use Premium plan for warm instances (costs extra)
   - Accept 1-5 second cold start delay

2. **Code optimization**:
   - Minimize dependencies
   - Use async/await patterns
   - Cache static data when possible
   - Lazy load modules

3. **Timeout settings**:
   - Consumption plan: Max 10 minutes (5 minutes default)
   - Set realistic timeouts
   - Monitor actual execution times

## 🔧 Configuration Best Practices

### Application Settings
```hcl
app_settings = {
  "FUNCTIONS_WORKER_RUNTIME" = "node"
  "WEBSITE_NODE_DEFAULT_VERSION" = "~18"
  "AzureWebJobsStorage" = azurerm_storage_account.main.primary_connection_string
  "COSMOS_CONNECTION" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.cosmos.id})"
}
```

### Host.json Configuration
```json
{
  "version": "2.0",
  "functionTimeout": "00:05:00",
  "logging": {
    "applicationInsights": {
      "samplingSettings": {
        "isEnabled": true,
        "maxTelemetryItemsPerSecond": 1
      }
    },
    "logLevel": {
      "default": "Warning"
    }
  }
}
```

### Managed Identity (Recommended)
```hcl
resource "azurerm_linux_function_app" "main" {
  name                = "my-function"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  
  service_plan_id            = azurerm_service_plan.main.id
  storage_account_name       = azurerm_storage_account.main.name
  storage_account_access_key = azurerm_storage_account.main.primary_access_key

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      node_version = "18"
    }
  }
}
```

## 📈 Free Tier Monitoring

### Calculate Your Usage

**Monthly GB-seconds formula**:
```
Total GB-seconds = Σ (executions × duration_seconds × memory_GB)
```

**Example calculation**:
- API endpoint: 500K executions/month × 0.2s × 0.256GB = 25,600 GB-seconds
- Scheduled job: 1K executions/month × 5s × 1GB = 5,000 GB-seconds
- Webhook: 10K executions/month × 0.1s × 0.128GB = 128 GB-seconds
- **Total**: 30,728 GB-seconds (7.7% of free tier) ✅

### Azure Monitor Metrics

Key metrics to monitor:
- **Function Execution Count**: Track executions
- **Function Execution Units**: Monitor GB-seconds
- **Http 4xx/5xx**: Track errors
- **Response Time**: Monitor latency
- **Active Connections**: Track concurrent requests

### Cost Alert Example

```hcl
resource "azurerm_monitor_metric_alert" "function_executions" {
  name                = "function-high-executions"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_linux_function_app.main.id]
  description         = "Alert when executions exceed 90% of free tier"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "FunctionExecutionCount"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 900000  # 90% of 1M
  }

  action {
    action_group_id = azurerm_monitor_action_group.billing.id
  }
}
```

## 🛡️ Staying Within Free Tier

### Strategies

1. **Set conservative limits**:
   - Configure function throttling
   - Set appropriate timeouts
   - Monitor usage weekly

2. **Use efficient patterns**:
   - Batch operations when possible
   - Cache frequently used data
   - Minimize cold starts

3. **Optimize execution time**:
   - Profile code for bottlenecks
   - Use async operations
   - Minimize external calls

4. **Rate limiting**:
   - Implement request throttling
   - Use API Management for control
   - Queue requests with Service Bus

5. **Monitoring**:
   - Set alerts at 80% of free tier limits
   - Review Azure Monitor metrics weekly
   - Use billing alerts (see billing-alerts module)

## 🧪 Example Configurations

### Basic HTTP Function
```hcl
resource "azurerm_resource_group" "main" {
  name     = "functions-rg"
  location = "eastus"
}

resource "azurerm_storage_account" "main" {
  name                     = "funcstorageaccount"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "main" {
  name                = "functions-service-plan"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "Y1"  # Consumption plan (free tier)
}

resource "azurerm_linux_function_app" "main" {
  name                = "my-function-app"
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

  tags = {
    FreeTier = "true"
    Purpose  = "api-backend"
  }
}
```

### Timer Triggered Function
```hcl
resource "azurerm_linux_function_app" "scheduled" {
  name                = "scheduled-function"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  storage_account_name       = azurerm_storage_account.main.name
  storage_account_access_key = azurerm_storage_account.main.primary_access_key
  service_plan_id            = azurerm_service_plan.main.id

  site_config {
    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
  }
}

# function.json for timer trigger
# {
#   "bindings": [
#     {
#       "name": "timer",
#       "type": "timerTrigger",
#       "direction": "in",
#       "schedule": "0 0 8 * * *"  # Daily at 8 AM UTC
#     }
#   ]
# }
```

### Function with Cosmos DB
```hcl
resource "azurerm_linux_function_app" "cosmos" {
  name                = "cosmos-function"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  storage_account_name       = azurerm_storage_account.main.name
  storage_account_access_key = azurerm_storage_account.main.primary_access_key
  service_plan_id            = azurerm_service_plan.main.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "dotnet"
    "CosmosDBConnection" = azurerm_cosmosdb_account.main.primary_sql_connection_string
  }
}
```

## 🔒 Security Best Practices

1. **Never hardcode secrets**:
   - Use Azure Key Vault references
   - Use Managed Identity
   - Store connection strings securely

2. **Least privilege access**:
   - Use minimal RBAC roles
   - Scope permissions to specific resources
   - Avoid Contributor role when possible

3. **Network security**:
   - VNet integration (requires Premium, costs extra)
   - IP restrictions when possible
   - Use Private Endpoints for sensitive data

4. **Encryption**:
   - All data encrypted at rest (default)
   - Use HTTPS for all endpoints
   - Enable TLS 1.2 minimum

5. **Logging**:
   - Don't log sensitive data
   - Use structured logging
   - Set appropriate log retention

## 🐛 Troubleshooting

### Issue: Exceeding Free Tier Executions

**Symptoms**: Unexpected charges, billing alerts triggered

**Solutions**:
1. Check Azure Monitor for execution count
2. Identify which function has high traffic
3. Implement request throttling
4. Add rate limiting in application
5. Use Service Bus to queue requests

### Issue: High GB-seconds Usage

**Symptoms**: Charges despite low execution count

**Solutions**:
1. Review function memory consumption
2. Optimize execution time
3. Profile code for bottlenecks
4. Reduce timeout if too high
5. Cache data to reduce execution time

### Issue: Cold Start Performance

**Symptoms**: First request is slow (5+ seconds)

**Solutions**:
1. Keep deployment package small
2. Minimize dependencies
3. Use runtime-specific optimizations
4. Accept cold starts or use Premium plan (costs extra)
5. Implement warming strategy if needed

### Issue: Function Timeouts

**Symptoms**: "Function timeout" errors

**Solutions**:
1. Increase timeout (max 10 minutes for Consumption)
2. Optimize code for faster execution
3. Break into smaller functions
4. Use Durable Functions for long operations

### Issue: Storage Account Errors

**Symptoms**: Function fails to start, storage errors

**Solutions**:
1. Verify storage account exists and is accessible
2. Check connection string in app settings
3. Ensure storage account is in same region
4. Check for network restrictions

## 🔗 Related Resources

### Azure Documentation
- [Azure Functions Pricing](https://azure.microsoft.com/pricing/details/functions/)
- [Azure Functions Developer Guide](https://docs.microsoft.com/azure/azure-functions/)
- [Best Practices](https://docs.microsoft.com/azure/azure-functions/functions-best-practices)
- [Limits and Quotas](https://docs.microsoft.com/azure/azure-functions/functions-scale)

### TAF Modules
- [billing-alerts](../billing-alerts/) - Monitor function costs
- [cosmos-db](../cosmos-db/) - Database for functions
- [event-grid](../event-grid/) - Event triggers for functions
- [service-bus](../service-bus/) - Queue triggers for functions
- [notification-hubs](../notification-hubs/) - Push notifications from functions

### Tools
- [Azure Functions Core Tools](https://github.com/Azure/azure-functions-core-tools)
- [VS Code Azure Functions Extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurefunctions)
- [Azure Functions for Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app)

## 📝 Implementation Checklist

When implementing Azure Functions:

- [ ] Deploy billing-alerts module first
- [ ] Use Consumption plan (Y1 SKU) for free tier
- [ ] Set realistic timeout (not max)
- [ ] Implement proper error handling
- [ ] Use Managed Identity for authentication
- [ ] Enable Application Insights (sampling to reduce costs)
- [ ] Set up Azure Monitor alerts for executions
- [ ] Calculate expected GB-seconds usage
- [ ] Test thoroughly in sandbox
- [ ] Monitor usage for first week
- [ ] Optimize based on actual metrics
- [ ] Document function purpose and limits
- [ ] Tag resources for cost tracking

## 💡 Tips for Staying Free

1. **Be efficient**: Optimize code to reduce duration
2. **Use Consumption plan**: Only plan with free tier
3. **Monitor actively**: Check metrics weekly
4. **Use batching**: Process multiple items per execution
5. **Cache wisely**: Store static data when possible
6. **Set alarms**: At 80% of free tier limits
7. **Document usage**: Track GB-seconds per function
8. **Review monthly**: Adjust based on patterns

## 📞 Support

- [TAF Issues](https://github.com/lstasi/taf/issues)
- [Azure Support](https://azure.microsoft.com/support/)
- [Azure Functions Forum](https://docs.microsoft.com/answers/topics/azure-functions.html)

---

**Remember**: Always deploy [billing-alerts](../billing-alerts/) first! 🛡️
