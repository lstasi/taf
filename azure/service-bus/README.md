# Azure Service Bus (Always Free) Documentation

**Current Phase**: Documentation

This document describes Azure Service Bus and how to use it within the always-free tier limits.

## 🎯 Always Free Limits

Azure Service Bus offers a **Basic tier** with always-free hours (not limited to 12 months):

- **750 hours/month** of Basic tier (perpetually free)
- **Approximately 31 days** of continuous operation
- **Basic tier only**: Free hours apply only to Basic tier
- **No time limit**: These limits never expire

### What Does 750 Hours Mean?

- **1 Namespace hour** = 1 hour of namespace running
- **750 hours** = Approximately 31 days
- **Single namespace**: Keep one namespace running continuously
- **Multiple namespaces**: Hours are divided (e.g., 2 namespaces = 375 hours each)

### Basic Tier Limitations

| Feature | Basic Tier (Free) | Standard Tier | Premium Tier |
|---------|-------------------|---------------|--------------|
| **Queues** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Topics/Subscriptions** | ❌ No | ✅ Yes | ✅ Yes |
| **Sessions** | ❌ No | ✅ Yes | ✅ Yes |
| **Dead-lettering** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Scheduled messages** | ❌ No | ✅ Yes | ✅ Yes |
| **Max message size** | 256 KB | 256 KB | 100 MB |
| **Partitioning** | ❌ No | ✅ Yes | ✅ Yes |

## ⚠️ What Causes Charges

You will incur charges if:
- ❌ Use Standard or Premium tier
- ❌ Run multiple namespaces (divides free hours)
- ❌ Use Topics/Subscriptions (requires Standard)
- ❌ Use Sessions (requires Standard)
- ❌ Exceed 750 hours/month (if multiple namespaces)
- ❌ Large volume of messaging operations (brokered connections)

## 🏗️ Use Cases Within Free Tier

### Excellent Use Cases
- ✅ **Simple queueing**: One producer, one consumer
- ✅ **Job queues**: Async task processing
- ✅ **Decoupling services**: Loose service coupling
- ✅ **Load leveling**: Buffer request spikes
- ✅ **Webhook processing**: Queue incoming webhooks
- ✅ **Batch processing**: Queue items for batch jobs

### Requires Standard Tier (Not Free)
- ❌ **Pub/Sub patterns**: Topics/subscriptions required
- ❌ **Session-based processing**: Ordered message handling
- ❌ **Scheduled delivery**: Deferred messages
- ❌ **Large messages**: >256 KB payload

## 🎨 Architecture Patterns

### Pattern 1: Simple Queue Processing
```
Producer (sends messages)
    ↓
Service Bus Queue (Basic tier - free)
    ↓
Consumer (processes messages)
```

**Use case**: Async job processing
**Cost**: Free within 750 hours

### Pattern 2: Function + Queue
```
HTTP Trigger (1M requests/month)
    ↓
Azure Function (queues work)
    ↓
Service Bus Queue
    ↓
Azure Function (processes work)
```

**Use case**: Decoupled processing
**Cost**: Free within limits

### Pattern 3: Load Leveling
```
API Gateway
    ↓
Service Bus Queue (buffers requests)
    ↓
Backend Service (processes at own pace)
```

**Use case**: Handle traffic spikes
**Cost**: Free within 750 hours

## 📊 Queue Configuration

### Message Properties

| Property | Description | Best Practice |
|----------|-------------|---------------|
| **Time to Live (TTL)** | How long messages live | Set reasonable limit |
| **Lock Duration** | How long message is locked | Match processing time |
| **Max Delivery Count** | Retries before dead-lettering | 3-5 attempts |
| **Max Size** | Maximum message size | 256 KB in Basic |

### Queue Settings

```hcl
resource "azurerm_servicebus_queue" "main" {
  name         = "my-queue"
  namespace_id = azurerm_servicebus_namespace.main.id

  # Enable dead-lettering (available in Basic)
  dead_lettering_on_message_expiration = true

  # Message settings
  default_message_ttl                  = "P14D"  # 14 days
  lock_duration                        = "PT1M"  # 1 minute
  max_delivery_count                   = 5       # 5 retries
  max_size_in_megabytes               = 1024    # 1 GB queue size

  # Not available in Basic tier
  # enable_partitioning = false (Basic doesn't support)
  # requires_session = false (Basic doesn't support)
}
```

## 🔧 Configuration Best Practices

### Namespace Setup

```hcl
resource "azurerm_resource_group" "main" {
  name     = "servicebus-rg"
  location = "eastus"
}

resource "azurerm_servicebus_namespace" "main" {
  name                = "my-servicebus-ns"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  
  # CRITICAL: Use Basic tier for free hours
  sku = "Basic"

  tags = {
    FreeTier = "true"
    Purpose  = "job-queue"
  }
}
```

### Queue Setup

```hcl
resource "azurerm_servicebus_queue" "jobs" {
  name         = "job-queue"
  namespace_id = azurerm_servicebus_namespace.main.id

  # Recommended settings for free tier
  default_message_ttl                  = "P7D"   # 7 days
  lock_duration                        = "PT1M"  # 1 minute
  max_delivery_count                   = 5
  max_size_in_megabytes               = 1024
  dead_lettering_on_message_expiration = true
}

resource "azurerm_servicebus_queue" "dead_letter" {
  name         = "dead-letter-queue"
  namespace_id = azurerm_servicebus_namespace.main.id

  # Long TTL for dead letters (investigation)
  default_message_ttl    = "P30D"  # 30 days
  max_size_in_megabytes = 1024
}
```

### Authorization Rules

```hcl
# Sender rule (for producers)
resource "azurerm_servicebus_queue_authorization_rule" "sender" {
  name     = "sender"
  queue_id = azurerm_servicebus_queue.jobs.id

  listen = false
  send   = true
  manage = false
}

# Listener rule (for consumers)
resource "azurerm_servicebus_queue_authorization_rule" "listener" {
  name     = "listener"
  queue_id = azurerm_servicebus_queue.jobs.id

  listen = true
  send   = false
  manage = false
}

output "sender_connection_string" {
  value     = azurerm_servicebus_queue_authorization_rule.sender.primary_connection_string
  sensitive = true
}

output "listener_connection_string" {
  value     = azurerm_servicebus_queue_authorization_rule.listener.primary_connection_string
  sensitive = true
}
```

## 📈 Free Tier Monitoring

### Track Namespace Hours

The free tier provides 750 hours per month. Monitor usage:

```hcl
resource "azurerm_monitor_metric_alert" "servicebus_messages" {
  name                = "servicebus-high-messages"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_servicebus_namespace.main.id]
  description         = "Alert on high message count"

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = "Messages"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 10000
  }

  action {
    action_group_id = azurerm_monitor_action_group.billing.id
  }
}
```

### Track Queue Depth

```hcl
resource "azurerm_monitor_metric_alert" "queue_depth" {
  name                = "queue-depth-alert"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_servicebus_namespace.main.id]
  description         = "Alert when queue depth is high"

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = "ActiveMessages"
    aggregation      = "Maximum"
    operator         = "GreaterThan"
    threshold        = 1000

    dimension {
      name     = "EntityName"
      operator = "Include"
      values   = [azurerm_servicebus_queue.jobs.name]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
```

### Key Metrics to Monitor

- **ActiveMessages**: Messages waiting to be processed
- **DeadletteredMessages**: Messages in dead-letter queue
- **IncomingMessages**: Messages received
- **OutgoingMessages**: Messages delivered
- **SuccessfulRequests**: Successful operations
- **ThrottledRequests**: Requests throttled due to limits

## 🛡️ Staying Within Free Tier

### Strategies

1. **Single namespace**:
   - Use only one namespace
   - 750 hours = ~31 days continuous
   - Multiple namespaces divide hours

2. **Use queues only**:
   - Topics require Standard tier
   - Design around queue patterns
   - Fan-out via multiple queues

3. **Efficient message handling**:
   - Complete messages promptly
   - Handle errors properly
   - Use dead-lettering

4. **Optimize message size**:
   - Keep messages small (<256 KB)
   - Reference large data instead
   - Use compression if needed

5. **Monitoring**:
   - Track queue depth
   - Monitor dead-letter queues
   - Set up billing alerts

## 🧪 Example Configurations

### Complete Basic Tier Setup

```hcl
# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "servicebus-free-tier-rg"
  location = "eastus"
}

# Service Bus Namespace (Basic - Free Tier)
resource "azurerm_servicebus_namespace" "main" {
  name                = "myservicebus${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Basic"

  tags = {
    FreeTier    = "true"
    Environment = "production"
  }
}

# Job Queue
resource "azurerm_servicebus_queue" "jobs" {
  name         = "job-queue"
  namespace_id = azurerm_servicebus_namespace.main.id

  default_message_ttl                  = "P7D"
  lock_duration                        = "PT2M"
  max_delivery_count                   = 5
  max_size_in_megabytes               = 1024
  dead_lettering_on_message_expiration = true
}

# Priority Queue
resource "azurerm_servicebus_queue" "priority" {
  name         = "priority-queue"
  namespace_id = azurerm_servicebus_namespace.main.id

  default_message_ttl    = "P1D"
  lock_duration          = "PT30S"
  max_delivery_count     = 3
  max_size_in_megabytes = 256
}

# Random suffix for globally unique name
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Outputs
output "namespace_connection_string" {
  value     = azurerm_servicebus_namespace.main.default_primary_connection_string
  sensitive = true
}
```

### Service Bus with Azure Functions

```hcl
# Function App for queue processing
resource "azurerm_service_plan" "main" {
  name                = "servicebus-plan"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "Y1"  # Consumption (free tier)
}

resource "azurerm_linux_function_app" "processor" {
  name                = "queue-processor"
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
    "ServiceBusConnection" = azurerm_servicebus_namespace.main.default_primary_connection_string
    "FUNCTIONS_WORKER_RUNTIME" = "node"
  }
}

# Function example (function.json):
# {
#   "bindings": [
#     {
#       "name": "message",
#       "type": "serviceBusTrigger",
#       "direction": "in",
#       "queueName": "job-queue",
#       "connection": "ServiceBusConnection"
#     }
#   ]
# }
```

### Producer Example (Node.js)

```javascript
const { ServiceBusClient } = require("@azure/service-bus");

async function sendMessage(message) {
  const client = new ServiceBusClient(process.env.SERVICEBUS_CONNECTION);
  const sender = client.createSender("job-queue");
  
  try {
    await sender.sendMessages({
      body: message,
      contentType: "application/json"
    });
  } finally {
    await sender.close();
    await client.close();
  }
}
```

### Consumer Example (Node.js)

```javascript
const { ServiceBusClient } = require("@azure/service-bus");

async function processMessages() {
  const client = new ServiceBusClient(process.env.SERVICEBUS_CONNECTION);
  const receiver = client.createReceiver("job-queue");
  
  const messages = await receiver.receiveMessages(10, {
    maxWaitTimeInMs: 5000
  });
  
  for (const message of messages) {
    try {
      // Process message
      console.log("Processing:", message.body);
      await receiver.completeMessage(message);
    } catch (error) {
      // Dead-letter on failure
      await receiver.deadLetterMessage(message, {
        deadLetterReason: "ProcessingError",
        deadLetterErrorDescription: error.message
      });
    }
  }
  
  await receiver.close();
  await client.close();
}
```

## 🔒 Security Best Practices

1. **Use Managed Identity**:
   ```hcl
   resource "azurerm_role_assignment" "function_servicebus" {
     scope                = azurerm_servicebus_namespace.main.id
     role_definition_name = "Azure Service Bus Data Receiver"
     principal_id         = azurerm_linux_function_app.processor.identity[0].principal_id
   }
   ```

2. **Separate sender/receiver credentials**:
   - Create specific authorization rules
   - Sender only needs Send permission
   - Receiver only needs Listen permission

3. **Rotate keys regularly**:
   - Use secondary keys during rotation
   - Update applications with new keys
   - Regenerate primary keys

4. **Network security**:
   - IP filtering (Premium tier)
   - Private endpoints (Premium tier)
   - Service endpoints (Standard+)

## 🐛 Troubleshooting

### Issue: Messages Not Processing

**Symptoms**: Queue depth increasing, messages stuck

**Solutions**:
1. Check consumer function/app is running
2. Verify connection string
3. Check for processing errors
4. Review dead-letter queue
5. Increase lock duration if processing takes long

### Issue: Messages Going to Dead-Letter

**Symptoms**: High dead-letter count

**Solutions**:
1. Check consumer error logs
2. Review message format
3. Increase max_delivery_count
4. Fix processing logic
5. Reprocess dead-letter messages

### Issue: Throttling Errors

**Symptoms**: 429 Too Many Requests

**Solutions**:
1. Implement retry with backoff
2. Reduce message send rate
3. Check brokered connections limit
4. Consider batching messages

### Issue: Lock Lost

**Symptoms**: "Lock has expired" errors

**Solutions**:
1. Increase lock_duration
2. Process messages faster
3. Renew locks for long processing
4. Split into smaller messages

## 🔗 Related Resources

### Azure Documentation
- [Service Bus Pricing](https://azure.microsoft.com/pricing/details/service-bus/)
- [Service Bus Overview](https://docs.microsoft.com/azure/service-bus-messaging/service-bus-messaging-overview)
- [Queues Guide](https://docs.microsoft.com/azure/service-bus-messaging/service-bus-queues-topics-subscriptions)
- [Best Practices](https://docs.microsoft.com/azure/service-bus-messaging/service-bus-performance-improvements)

### TAF Modules
- [billing-alerts](../billing-alerts/) - Monitor costs
- [functions](../functions/) - Queue processors
- [event-grid](../event-grid/) - Event notifications
- [cosmos-db](../cosmos-db/) - Message persistence

### Tools
- [Service Bus Explorer](https://github.com/paolosalvatori/ServiceBusExplorer)
- [Terraform Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace)

## 📝 Implementation Checklist

When implementing Service Bus:

- [ ] Deploy billing-alerts module first
- [ ] Use Basic tier (sku = "Basic")
- [ ] Use only one namespace
- [ ] Design queue-based patterns (no topics in Basic)
- [ ] Configure appropriate TTL and lock duration
- [ ] Set up dead-letter queue handling
- [ ] Monitor queue depth
- [ ] Implement proper error handling
- [ ] Use separate authorization rules
- [ ] Test message flow end-to-end
- [ ] Document queue schema
- [ ] Tag resources for cost tracking

## 💡 Tips for Staying Free

1. **Single namespace**: Don't create multiple
2. **Basic tier only**: No Standard features
3. **Queue patterns**: No topics needed
4. **Monitor depth**: Alert on queue buildup
5. **Handle errors**: Avoid dead-letter growth
6. **Complete promptly**: Don't hold locks
7. **Small messages**: Stay under 256 KB
8. **Review monthly**: Check usage patterns

## 📞 Support

- [TAF Issues](https://github.com/lstasi/taf/issues)
- [Azure Support](https://azure.microsoft.com/support/)
- [Service Bus Forum](https://docs.microsoft.com/answers/topics/azure-service-bus.html)

---

**Remember**: Always deploy [billing-alerts](../billing-alerts/) first! 🛡️
