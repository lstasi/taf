# Azure Event Grid (Always Free) Documentation

**Current Phase**: Documentation

This document describes Azure Event Grid and how to use it within the always-free tier limits.

## 🎯 Always Free Limits

Azure Event Grid offers an **always-free tier** (not limited to 12 months):

- **100,000 operations per month** (perpetually free)
- **System topics are always free**
- **Custom topics**: First 100K operations/month free
- **No time limit**: These limits never expire

### What Counts as an Operation?

Operations include:
- **Publishing events**: Each event published
- **Event delivery attempts**: Each delivery try
- **Management operations**: Creating/updating topics
- **Advanced filtering**: Each filter evaluation

### Practical Examples

**Example 1: Low-Volume Event Processing**
- Events published: 50,000/month
- Average deliveries per event: 1
- **Total operations**: 100,000 ✅ Within free tier

**Example 2: Multi-Subscriber Pattern**
- Events published: 25,000/month
- Subscribers per event: 3
- Deliveries: 75,000/month
- **Total operations**: 100,000 ✅ Within free tier

**Example 3: Webhook Integration**
- GitHub events: 10,000/month
- Azure resource events: 20,000/month
- Function triggers: 30,000/month
- **Total operations**: 60,000 ✅ Within free tier

## ⚠️ What Causes Charges

You will incur charges if:
- ❌ Exceed 100,000 operations/month
- ❌ High event fan-out (many subscribers)
- ❌ Excessive retry attempts
- ❌ Using advanced filtering extensively
- ❌ Premium tier features
- ❌ High bandwidth with large events (>64KB)

## 🏗️ Use Cases Within Free Tier

### Excellent Use Cases
- ✅ **Azure resource events**: React to Azure changes
- ✅ **Application events**: Custom application messaging
- ✅ **Webhook routing**: GitHub, Azure DevOps integration
- ✅ **Serverless triggers**: Trigger Azure Functions
- ✅ **Microservices communication**: Event-driven architecture
- ✅ **IoT scenarios**: Device event processing
- ✅ **Automation**: Respond to Azure events automatically

### Consider Alternatives For
- ⚠️ **High-volume messaging**: >100K events/month
- ⚠️ **Many subscribers**: Fan-out multiplies operations
- ⚠️ **Large payloads**: >64KB adds costs
- ⚠️ **Guaranteed delivery**: Consider Service Bus
- ⚠️ **Message ordering**: Event Grid doesn't guarantee order

## 🎨 Architecture Patterns

### Pattern 1: Azure Resource Events
```
Azure Resource (VM, Storage, etc.)
    ↓ (system topic - free)
Event Grid
    ↓
Azure Function (processes event)
```

**Use case**: React to Azure resource changes
**Cost**: Free (system topics are always free)

### Pattern 2: Custom Application Events
```
Application (publishes events)
    ↓
Custom Topic (100K ops/month)
    ↓
Multiple Subscribers (Functions, Webhooks)
```

**Use case**: Microservices communication
**Cost**: Free within 100K operations

### Pattern 3: Event-Driven Automation
```
GitHub Webhook → Event Grid → Azure Function → Cosmos DB
```

**Use case**: CI/CD automation
**Cost**: Free within limits

### Pattern 4: Fan-Out Pattern
```
Publisher → Event Grid Topic
                ↓
    ┌───────────┼───────────┐
    ↓           ↓           ↓
Function A  Function B  Webhook
```

**Use case**: Distribute events to multiple handlers
**Cost**: Watch operation count (3x per event)

## 📊 Event Grid Concepts

### System Topics vs Custom Topics

| Feature | System Topic | Custom Topic |
|---------|--------------|--------------|
| **Source** | Azure services | Your application |
| **Cost** | Always free | First 100K free |
| **Management** | Azure-managed | You manage |
| **Use case** | Azure events | App events |

### Event Schema

```json
{
  "id": "unique-event-id",
  "eventType": "MyApp.Items.ItemCreated",
  "subject": "/myapp/items/item123",
  "data": {
    "itemId": "item123",
    "name": "New Item",
    "createdAt": "2024-01-15T10:30:00Z"
  },
  "dataVersion": "1.0",
  "eventTime": "2024-01-15T10:30:00Z"
}
```

### CloudEvents Schema (Alternative)

```json
{
  "specversion": "1.0",
  "type": "MyApp.Items.ItemCreated",
  "source": "/myapp/items",
  "id": "unique-event-id",
  "time": "2024-01-15T10:30:00Z",
  "data": {
    "itemId": "item123",
    "name": "New Item"
  }
}
```

## 🔧 Configuration Best Practices

### Custom Topic Setup

```hcl
resource "azurerm_resource_group" "main" {
  name     = "eventgrid-rg"
  location = "eastus"
}

resource "azurerm_eventgrid_topic" "main" {
  name                = "my-app-events"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  input_schema = "EventGridSchema"  # or "CloudEventSchemaV1_0"

  tags = {
    FreeTier = "true"
    Purpose  = "application-events"
  }
}

output "topic_endpoint" {
  value = azurerm_eventgrid_topic.main.endpoint
}

output "topic_key" {
  value     = azurerm_eventgrid_topic.main.primary_access_key
  sensitive = true
}
```

### Event Subscription to Azure Function

```hcl
resource "azurerm_eventgrid_event_subscription" "function" {
  name  = "function-subscription"
  scope = azurerm_eventgrid_topic.main.id

  azure_function_endpoint {
    function_id = "${azurerm_linux_function_app.main.id}/functions/ProcessEvent"
    max_events_per_batch              = 1
    preferred_batch_size_in_kilobytes = 64
  }

  included_event_types = [
    "MyApp.Items.ItemCreated",
    "MyApp.Items.ItemUpdated"
  ]

  retry_policy {
    max_delivery_attempts = 3
    event_time_to_live    = 1440  # 24 hours
  }
}
```

### Event Subscription to Webhook

```hcl
resource "azurerm_eventgrid_event_subscription" "webhook" {
  name  = "webhook-subscription"
  scope = azurerm_eventgrid_topic.main.id

  webhook_endpoint {
    url = "https://myapp.example.com/api/events"
    max_events_per_batch              = 1
    preferred_batch_size_in_kilobytes = 64
  }

  included_event_types = [
    "MyApp.Items.ItemCreated"
  ]

  # Filter to reduce operations
  advanced_filter {
    string_contains {
      key    = "data.priority"
      values = ["high", "critical"]
    }
  }
}
```

### System Topic for Azure Resources

```hcl
# System topic for Storage Account events
resource "azurerm_eventgrid_system_topic" "storage" {
  name                   = "storage-events"
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  source_arm_resource_id = azurerm_storage_account.main.id
  topic_type             = "Microsoft.Storage.StorageAccounts"

  tags = {
    FreeTier = "true"
  }
}

resource "azurerm_eventgrid_system_topic_event_subscription" "blob" {
  name                = "blob-created"
  system_topic        = azurerm_eventgrid_system_topic.storage.name
  resource_group_name = azurerm_resource_group.main.name

  azure_function_endpoint {
    function_id = "${azurerm_linux_function_app.main.id}/functions/ProcessBlob"
  }

  included_event_types = [
    "Microsoft.Storage.BlobCreated"
  ]
}
```

## 📈 Free Tier Monitoring

### Track Operations

```hcl
resource "azurerm_monitor_metric_alert" "eventgrid_ops" {
  name                = "eventgrid-high-operations"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_eventgrid_topic.main.id]
  description         = "Alert when operations exceed 80% of free tier"

  criteria {
    metric_namespace = "Microsoft.EventGrid/topics"
    metric_name      = "PublishSuccessCount"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 80000  # 80% of 100K
  }

  action {
    action_group_id = azurerm_monitor_action_group.billing.id
  }

  window_size = "P30D"  # 30-day window
  frequency   = "P1D"   # Check daily
}
```

### Track Delivery Failures

```hcl
resource "azurerm_monitor_metric_alert" "eventgrid_failures" {
  name                = "eventgrid-delivery-failures"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_eventgrid_topic.main.id]
  description         = "Alert on delivery failures"

  criteria {
    metric_namespace = "Microsoft.EventGrid/topics"
    metric_name      = "DeliveryAttemptFailCount"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 100
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
```

### Key Metrics to Monitor

- **PublishSuccessCount**: Events successfully published
- **PublishFailCount**: Failed publish attempts
- **DeliverySuccessCount**: Successful deliveries
- **DeliveryAttemptFailCount**: Failed delivery attempts
- **DroppedEventCount**: Events dropped (no subscription)
- **MatchedEventCount**: Events matching subscriptions

## 🛡️ Staying Within Free Tier

### Strategies

1. **Minimize subscribers**:
   - Each subscriber multiplies operations
   - Combine logic where possible
   - Use filtering to reduce deliveries

2. **Use filtering**:
   - Filter events at Event Grid level
   - Reduces delivery attempts
   - Use subject prefix/suffix filters

3. **Optimize retry policy**:
   - Reduce max delivery attempts
   - Failed retries count as operations
   - Handle errors in handlers

4. **Use system topics**:
   - System topics are always free
   - No operation charges
   - Best for Azure resource events

5. **Batch events**:
   - Publish fewer, larger events
   - Each publish is one operation
   - Reduce frequency where possible

### Event Filtering Examples

```hcl
# Subject filtering (simple, efficient)
resource "azurerm_eventgrid_event_subscription" "filtered" {
  name  = "filtered-subscription"
  scope = azurerm_eventgrid_topic.main.id

  subject_filter {
    subject_begins_with = "/orders/priority-"
    subject_ends_with   = "/created"
  }
}

# Advanced filtering (more flexible)
resource "azurerm_eventgrid_event_subscription" "advanced" {
  name  = "advanced-subscription"
  scope = azurerm_eventgrid_topic.main.id

  advanced_filter {
    string_in {
      key    = "data.region"
      values = ["us-east", "us-west"]
    }
  }

  advanced_filter {
    number_greater_than {
      key   = "data.amount"
      value = 1000
    }
  }
}
```

## 🧪 Example Configurations

### Complete Event-Driven Setup

```hcl
# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "eventgrid-free-tier-rg"
  location = "eastus"
}

# Custom Topic
resource "azurerm_eventgrid_topic" "app" {
  name                = "app-events"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  input_schema        = "EventGridSchema"

  tags = {
    FreeTier = "true"
  }
}

# Function App for event processing
resource "azurerm_service_plan" "main" {
  name                = "eventgrid-plan"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "Y1"  # Consumption (free tier)
}

resource "azurerm_linux_function_app" "processor" {
  name                = "event-processor"
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
}

# Event Subscription
resource "azurerm_eventgrid_event_subscription" "process" {
  name  = "process-events"
  scope = azurerm_eventgrid_topic.app.id

  azure_function_endpoint {
    function_id = "${azurerm_linux_function_app.processor.id}/functions/ProcessEvent"
  }

  retry_policy {
    max_delivery_attempts = 3
    event_time_to_live    = 60  # 1 hour
  }
}
```

### System Topic for Storage Events

```hcl
resource "azurerm_storage_account" "main" {
  name                     = "eventstorageacct${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_eventgrid_system_topic" "storage" {
  name                   = "storage-events"
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  source_arm_resource_id = azurerm_storage_account.main.id
  topic_type             = "Microsoft.Storage.StorageAccounts"
}

resource "azurerm_eventgrid_system_topic_event_subscription" "blob_created" {
  name                = "blob-created"
  system_topic        = azurerm_eventgrid_system_topic.storage.name
  resource_group_name = azurerm_resource_group.main.name

  azure_function_endpoint {
    function_id = "${azurerm_linux_function_app.processor.id}/functions/ProcessBlob"
  }

  included_event_types = [
    "Microsoft.Storage.BlobCreated"
  ]

  subject_filter {
    subject_begins_with = "/blobServices/default/containers/uploads/"
  }
}
```

## 🔒 Security Best Practices

1. **Secure topic access**:
   - Use SAS tokens with limited scope
   - Rotate access keys regularly
   - Use Managed Identity where possible

2. **Validate webhooks**:
   - Implement validation endpoint
   - Verify event signatures
   - Use HTTPS only

3. **Filter events**:
   - Only subscribe to needed events
   - Use subject and advanced filters
   - Validate event data

4. **Secure handlers**:
   - Authenticate function endpoints
   - Use private endpoints (Premium)
   - Implement rate limiting

## 🐛 Troubleshooting

### Issue: Events Not Delivered

**Symptoms**: Events published but not received

**Solutions**:
1. Check subscription filters
2. Verify endpoint is accessible
3. Check handler logs
4. Review retry policy settings
5. Verify event type matches subscription

### Issue: High Operation Count

**Symptoms**: Approaching 100K limit quickly

**Solutions**:
1. Review number of subscribers
2. Check retry counts (reduce max attempts)
3. Implement better filtering
4. Consolidate subscribers
5. Batch events where possible

### Issue: Webhook Validation Failed

**Symptoms**: Subscription creation fails

**Solutions**:
1. Implement validation endpoint
2. Respond with validation code
3. Ensure endpoint returns 200 OK
4. Check firewall rules
5. Verify HTTPS certificate

### Issue: Dead-Lettering Events

**Symptoms**: Events going to dead-letter destination

**Solutions**:
1. Check handler errors
2. Increase timeout
3. Fix handler logic
4. Review dead-letter events
5. Reprocess if needed

## 🔗 Related Resources

### Azure Documentation
- [Event Grid Pricing](https://azure.microsoft.com/pricing/details/event-grid/)
- [Event Grid Overview](https://docs.microsoft.com/azure/event-grid/overview)
- [System Topics](https://docs.microsoft.com/azure/event-grid/system-topics)
- [Event Handlers](https://docs.microsoft.com/azure/event-grid/event-handlers)

### TAF Modules
- [billing-alerts](../billing-alerts/) - Monitor Event Grid costs
- [functions](../functions/) - Event handlers
- [service-bus](../service-bus/) - Alternative for guaranteed delivery
- [cosmos-db](../cosmos-db/) - Event storage

### Tools
- [Azure Event Grid Viewer](https://docs.microsoft.com/azure/event-grid/select-event-handler)
- [Terraform Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_topic)

## 📝 Implementation Checklist

When implementing Event Grid:

- [ ] Deploy billing-alerts module first
- [ ] Use system topics for Azure events (free)
- [ ] Calculate expected operations/month
- [ ] Implement event filtering
- [ ] Set conservative retry policy
- [ ] Monitor operation count
- [ ] Test event flow end-to-end
- [ ] Implement proper error handling
- [ ] Secure topic access
- [ ] Document event schema
- [ ] Tag resources for cost tracking

## 💡 Tips for Staying Free

1. **Use system topics**: Always free for Azure events
2. **Minimize subscribers**: Each multiplies operations
3. **Filter early**: Use Event Grid filters
4. **Reduce retries**: Lower max_delivery_attempts
5. **Monitor actively**: Track operations weekly
6. **Batch when possible**: Fewer, larger events
7. **Use dead-letter**: Investigate failures
8. **Review monthly**: Adjust based on patterns

## 📞 Support

- [TAF Issues](https://github.com/lstasi/taf/issues)
- [Azure Support](https://azure.microsoft.com/support/)
- [Event Grid Forum](https://docs.microsoft.com/answers/topics/azure-event-grid.html)

---

**Remember**: Always deploy [billing-alerts](../billing-alerts/) first! 🛡️
