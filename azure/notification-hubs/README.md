# Azure Notification Hubs (Always Free) Documentation

**Current Phase**: Documentation

This document describes Azure Notification Hubs and how to use it within the always-free tier limits.

## 🎯 Always Free Limits

Azure Notification Hubs offers a **Free tier** (not limited to 12 months):

- **1 Million push notifications** per month (perpetually free)
- **500 active devices** maximum
- **50,000 installations** maximum
- **No time limit**: These limits never expire

### What Counts as a Push?

- **1 Push** = 1 notification sent to 1 device
- **Broadcast** = 1 notification × number of devices
- **Tagged sends** = 1 notification × devices with tag

### Practical Examples

**Example 1: Small App**
- Active devices: 100
- Notifications per device/month: 500
- **Total pushes**: 50,000 ✅ Within free tier

**Example 2: Medium App**
- Active devices: 500 (max)
- Notifications per device/month: 200
- **Total pushes**: 100,000 ✅ Within free tier

**Example 3: Broadcast-Heavy**
- Active devices: 500 (max)
- Daily broadcasts: 5 × 500 = 2,500
- **Monthly total**: 75,000 ✅ Within free tier

## ⚠️ What Causes Charges

You will incur charges if:
- ❌ Exceed 1 million pushes/month
- ❌ Exceed 500 active devices
- ❌ Use Basic or Standard tier
- ❌ Need larger namespaces
- ❌ Need SLA guarantees
- ❌ Need telemetry features (Basic+)

## 🏗️ Use Cases Within Free Tier

### Excellent Use Cases
- ✅ **Small apps**: <500 users
- ✅ **Prototype/MVP**: Testing push notifications
- ✅ **Personal projects**: Side projects, learning
- ✅ **B2B apps**: Limited user base
- ✅ **Internal apps**: Company tools
- ✅ **IoT alerts**: Device notifications

### Consider Paid Tiers For
- ⚠️ **Large user bases**: >500 active devices
- ⚠️ **High-frequency notifications**: >1M pushes/month
- ⚠️ **Production SLA**: Need guaranteed uptime
- ⚠️ **Telemetry**: Need delivery tracking
- ⚠️ **Large payloads**: Need bigger messages

## 🎨 Architecture Patterns

### Pattern 1: Direct Push
```
Backend Service
    ↓
Notification Hub (Free tier)
    ↓
Mobile Device (iOS/Android/Windows)
```

**Use case**: Direct app notifications
**Cost**: Free within limits

### Pattern 2: Function-Triggered Push
```
Event Grid / Timer
    ↓
Azure Function (1M executions/month)
    ↓
Notification Hub
    ↓
Mobile Devices
```

**Use case**: Automated notifications
**Cost**: Free within limits

### Pattern 3: Event-Driven Notifications
```
Cosmos DB Change Feed
    ↓
Azure Function (processes changes)
    ↓
Notification Hub
    ↓
Mobile Devices
```

**Use case**: Real-time updates
**Cost**: Free within limits

## 📊 Supported Platforms

### Push Notification Services

| Platform | Service | Configuration Required |
|----------|---------|----------------------|
| **iOS** | APNs | Certificate or Token |
| **Android** | FCM | Server Key |
| **Windows** | WNS | Package SID & Secret |
| **Amazon** | ADM | Client ID & Secret |
| **Baidu** | Baidu | API Key & Secret |

### Device Registration

Devices register with:
- **Installation ID**: Unique device identifier
- **Push Handle**: Platform-specific token (APNs, FCM, etc.)
- **Tags**: Categories for targeted sends
- **Templates**: Custom notification formats

## 🔧 Configuration Best Practices

### Namespace and Hub Setup

```hcl
resource "azurerm_resource_group" "main" {
  name     = "notification-hubs-rg"
  location = "eastus"
}

resource "azurerm_notification_hub_namespace" "main" {
  name                = "my-notification-ns"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  namespace_type      = "NotificationHub"
  
  # CRITICAL: Use Free tier
  sku_name = "Free"

  tags = {
    FreeTier = "true"
    Purpose  = "push-notifications"
  }
}

resource "azurerm_notification_hub" "main" {
  name                = "my-notification-hub"
  namespace_name      = azurerm_notification_hub_namespace.main.name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  tags = {
    FreeTier = "true"
  }
}
```

### Apple Push Notification Service (APNs)

```hcl
resource "azurerm_notification_hub" "ios" {
  name                = "ios-notification-hub"
  namespace_name      = azurerm_notification_hub_namespace.main.name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  apns_credential {
    application_mode = "Production"  # or "Sandbox" for development
    bundle_id        = "com.example.myapp"
    key_id           = var.apns_key_id
    team_id          = var.apple_team_id
    token            = var.apns_auth_key  # .p8 file content
  }
}
```

### Firebase Cloud Messaging (FCM)

```hcl
resource "azurerm_notification_hub" "android" {
  name                = "android-notification-hub"
  namespace_name      = azurerm_notification_hub_namespace.main.name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  gcm_credential {
    api_key = var.fcm_server_key
  }
}
```

### Windows Notification Service (WNS)

```hcl
resource "azurerm_notification_hub" "windows" {
  name                = "windows-notification-hub"
  namespace_name      = azurerm_notification_hub_namespace.main.name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  wns_credential {
    package_sid     = var.wns_package_sid
    client_secret   = var.wns_client_secret
  }
}
```

## 📈 Free Tier Monitoring

### Track Push Count

Since Free tier doesn't include telemetry, monitor indirectly:

```hcl
# Custom metric tracking in your application
resource "azurerm_application_insights" "main" {
  name                = "push-analytics"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
}

# Track push sends in your application code
# and send to Application Insights
```

### Monitor Device Registrations

Track active devices to stay under 500:

```javascript
// Track installations in your backend
async function getInstallationCount() {
  // Use Notification Hubs REST API or SDK
  // to count installations periodically
}
```

### Alert on Approaching Limits

```hcl
# Set up alerts based on custom metrics
resource "azurerm_monitor_metric_alert" "push_count" {
  name                = "push-count-alert"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_application_insights.main.id]
  description         = "Alert when push count approaches limit"

  criteria {
    metric_namespace = "Azure.ApplicationInsights"
    metric_name      = "customMetrics/pushNotificationsSent"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 800000  # 80% of 1M
  }

  action {
    action_group_id = azurerm_monitor_action_group.billing.id
  }
}
```

## 🛡️ Staying Within Free Tier

### Strategies

1. **Limit active devices**:
   - Track installations (max 500)
   - Remove inactive devices
   - Implement device cleanup

2. **Optimize notification frequency**:
   - Batch notifications where possible
   - Use digest notifications
   - Avoid unnecessary broadcasts

3. **Use tags effectively**:
   - Target specific device groups
   - Avoid sending to all devices
   - Segment users appropriately

4. **Implement client-side filtering**:
   - Let app decide what to show
   - Reduce server-side sends
   - Use silent notifications

5. **Monitor usage**:
   - Track sends in your backend
   - Log notification events
   - Set up alerts

### Tag-Based Targeting

```javascript
// Instead of broadcast (500 devices = 500 pushes)
await notificationHubService.sendBroadcast(notification);

// Use tags for targeted sends
// Only users with "premium" tag (e.g., 50 devices = 50 pushes)
await notificationHubService.send(notification, "premium");

// Multiple tags (OR logic)
await notificationHubService.send(notification, "alert || important");
```

## 🧪 Example Configurations

### Complete Free Tier Setup

```hcl
# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "notification-free-tier-rg"
  location = "eastus"
}

# Notification Hub Namespace (Free Tier)
resource "azurerm_notification_hub_namespace" "main" {
  name                = "mynotificationns${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  namespace_type      = "NotificationHub"
  sku_name            = "Free"

  tags = {
    FreeTier    = "true"
    Environment = "production"
  }
}

# Notification Hub
resource "azurerm_notification_hub" "main" {
  name                = "app-notifications"
  namespace_name      = azurerm_notification_hub_namespace.main.name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  tags = {
    FreeTier = "true"
  }
}

# Random suffix for globally unique name
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Outputs
output "hub_name" {
  value = azurerm_notification_hub.main.name
}

output "namespace_name" {
  value = azurerm_notification_hub_namespace.main.name
}
```

### Function-Triggered Notifications

```hcl
# Function App for sending notifications
resource "azurerm_linux_function_app" "notifier" {
  name                = "push-notifier"
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
    "NOTIFICATION_HUB_CONNECTION" = azurerm_notification_hub_namespace.main.default_primary_connection_string
    "NOTIFICATION_HUB_NAME"       = azurerm_notification_hub.main.name
  }
}
```

### Backend Push Example (Node.js)

```javascript
const { NotificationHubsClient } = require("@azure/notification-hubs");

const connectionString = process.env.NOTIFICATION_HUB_CONNECTION;
const hubName = process.env.NOTIFICATION_HUB_NAME;

const client = new NotificationHubsClient(connectionString, hubName);

// Send to specific tags (targeted)
async function sendToSegment(message, tags) {
  const notification = {
    body: JSON.stringify({
      aps: { alert: message, sound: "default" },  // iOS
      data: { message: message }                   // Android
    })
  };
  
  return await client.sendNotification(notification, { tagExpression: tags });
}

// Register device
async function registerDevice(installationId, pushHandle, platform, tags) {
  const installation = {
    installationId: installationId,
    platform: platform,  // "apns", "gcm", "wns"
    pushChannel: pushHandle,
    tags: tags
  };
  
  return await client.createOrUpdateInstallation(installation);
}

// Remove inactive device
async function removeDevice(installationId) {
  return await client.deleteInstallation(installationId);
}
```

### iOS Client Registration (Swift)

```swift
import UserNotifications
import WindowsAzureMessaging

class NotificationService {
    let hubName = "your-hub-name"
    let connectionString = "your-connection-string"
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            guard granted else { return }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func didRegisterForRemoteNotifications(deviceToken: Data) {
        let hub = MSNotificationHub(connectionString: connectionString, hubPath: hubName)
        
        hub.registerNative(withDeviceToken: deviceToken, tags: ["user:123"]) { error in
            if let error = error {
                print("Registration failed: \(error)")
            }
        }
    }
}
```

### Android Client Registration (Kotlin)

```kotlin
import com.microsoft.windowsazure.messaging.NotificationHub

class NotificationService(private val context: Context) {
    private val hubName = "your-hub-name"
    private val connectionString = "your-connection-string"
    
    fun registerForPushNotifications(fcmToken: String) {
        Thread {
            try {
                val hub = NotificationHub(hubName, connectionString, context)
                val tags = setOf("user:123")
                
                hub.registerNative(fcmToken, tags)
                
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }.start()
    }
}
```

## 🔒 Security Best Practices

1. **Protect connection strings**:
   - Never expose in client apps
   - Use backend proxy for registration
   - Store in Key Vault

2. **Use SAS tokens**:
   ```hcl
   # Create limited access policy
   resource "azurerm_notification_hub_authorization_rule" "listen" {
     name                  = "ListenOnly"
     notification_hub_name = azurerm_notification_hub.main.name
     namespace_name        = azurerm_notification_hub_namespace.main.name
     resource_group_name   = azurerm_resource_group.main.name
     listen                = true
     send                  = false
     manage                = false
   }
   ```

3. **Validate registrations**:
   - Authenticate users before registration
   - Validate device tokens
   - Prevent unauthorized tag assignments

4. **Tag security**:
   - Use user-specific tags (e.g., "user:123")
   - Validate tag assignments server-side
   - Don't trust client-provided tags

## 🐛 Troubleshooting

### Issue: Notifications Not Received

**Symptoms**: Sends succeed but devices don't receive

**Solutions**:
1. Verify platform credentials (APNs, FCM)
2. Check device registration
3. Verify push token is current
4. Check notification payload format
5. Test with platform-specific tools

### Issue: Registration Failures

**Symptoms**: Devices can't register

**Solutions**:
1. Verify connection string
2. Check hub name spelling
3. Verify network connectivity
4. Check for expired credentials
5. Review registration payload

### Issue: Exceeding Device Limit

**Symptoms**: New registrations fail

**Solutions**:
1. Check installation count
2. Remove inactive devices
3. Implement device cleanup routine
4. Consider upgrading tier (if needed)

### Issue: APNs Certificate Expired

**Symptoms**: iOS notifications stop working

**Solutions**:
1. Generate new APNs key/certificate
2. Update hub configuration
3. Use token-based authentication (recommended)
4. Set up renewal reminders

## 🔗 Related Resources

### Azure Documentation
- [Notification Hubs Pricing](https://azure.microsoft.com/pricing/details/notification-hubs/)
- [Notification Hubs Overview](https://docs.microsoft.com/azure/notification-hubs/notification-hubs-push-notification-overview)
- [iOS Push Tutorial](https://docs.microsoft.com/azure/notification-hubs/ios-sdk-get-started)
- [Android Push Tutorial](https://docs.microsoft.com/azure/notification-hubs/android-sdk)

### TAF Modules
- [billing-alerts](../billing-alerts/) - Monitor costs
- [functions](../functions/) - Notification triggers
- [event-grid](../event-grid/) - Event-driven notifications
- [cosmos-db](../cosmos-db/) - User/device data

### Tools
- [Notification Hubs REST API](https://docs.microsoft.com/rest/api/notificationhubs/)
- [Azure SDK for JavaScript](https://www.npmjs.com/package/@azure/notification-hubs)
- [Terraform Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/notification_hub)

## 📝 Implementation Checklist

When implementing Notification Hubs:

- [ ] Deploy billing-alerts module first
- [ ] Use Free tier (sku_name = "Free")
- [ ] Configure platform credentials (APNs, FCM, WNS)
- [ ] Track device count (max 500)
- [ ] Implement device cleanup routine
- [ ] Use tags for targeted sends
- [ ] Monitor push count (max 1M/month)
- [ ] Test on all target platforms
- [ ] Secure connection strings
- [ ] Implement backend registration proxy
- [ ] Document notification formats
- [ ] Tag resources for cost tracking

## 💡 Tips for Staying Free

1. **Stay under 500 devices**: Monitor installations
2. **Target with tags**: Avoid broadcasts
3. **Clean up inactive**: Remove old registrations
4. **Track sends**: Log notification counts
5. **Use silent pushes**: Client-side filtering
6. **Batch when possible**: Reduce send count
7. **Review monthly**: Check usage patterns
8. **Set alerts**: At 80% of limits

## 📞 Support

- [TAF Issues](https://github.com/lstasi/taf/issues)
- [Azure Support](https://azure.microsoft.com/support/)
- [Notification Hubs Forum](https://docs.microsoft.com/answers/topics/azure-notification-hubs.html)

---

**Remember**: Always deploy [billing-alerts](../billing-alerts/) first! 🛡️
