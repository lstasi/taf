# Azure Billing Alerts Documentation

**⚠️ CRITICAL: Always configure billing protection FIRST before deploying any Azure resources!**

**Current Phase**: Documentation

This document describes strategies and patterns for monitoring Azure costs when using always-free resources. While always-free resources should not incur charges within their limits, billing protection is essential to catch misconfigurations or accidental usage of non-free resources.

## Why Billing Protection Matters

Even when using only always-free resources:
- Misconfigurations can deploy non-free resources
- Exceeding always-free limits incurs charges
- Accidental deployments can be costly
- Early detection prevents bill shock

## Azure Cost Management (Free)

Azure Cost Management is **completely free** to use:
- ✅ Cost analysis and reporting
- ✅ Budgets with alerts
- ✅ Cost recommendations
- ✅ Export data to storage

## Recommended Billing Protection Strategy

### 1. Azure Budgets (Free)

Create budgets to track and alert on spending:

```hcl
resource "azurerm_consumption_budget_subscription" "monthly" {
  name            = "monthly-budget"
  subscription_id = data.azurerm_subscription.current.id

  amount     = 10
  time_grain = "Monthly"

  time_period {
    start_date = "2024-01-01T00:00:00Z"
    end_date   = "2025-12-31T23:59:59Z"
  }

  notification {
    enabled   = true
    threshold = 50.0
    operator  = "GreaterThan"

    contact_emails = ["alerts@example.com"]
  }

  notification {
    enabled        = true
    threshold      = 80.0
    operator       = "GreaterThan"
    threshold_type = "Actual"

    contact_emails = ["alerts@example.com"]
  }

  notification {
    enabled        = true
    threshold      = 100.0
    operator       = "GreaterThan"
    threshold_type = "Forecasted"

    contact_emails = ["alerts@example.com"]
  }
}
```

### 2. Action Groups (Free)

Configure notification channels:

```hcl
resource "azurerm_monitor_action_group" "billing" {
  name                = "billing-alerts"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "billing"

  email_receiver {
    name                    = "admin"
    email_address           = "admin@example.com"
    use_common_alert_schema = true
  }

  webhook_receiver {
    name        = "slack"
    service_uri = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
  }
}
```

### 3. Cost Anomaly Alerts (Preview)

Azure can detect unusual spending patterns:

```hcl
resource "azurerm_cost_anomaly_alert" "main" {
  name            = "cost-anomaly-alert"
  display_name    = "Cost Anomaly Detection"
  subscription_id = data.azurerm_subscription.current.id
  email_subject   = "Azure Cost Anomaly Detected"
  email_addresses = ["alerts@example.com"]
}
```

## Advanced Example

```hcl
module "billing_alerts" {
  source = "./azure/billing-alerts"
  
  # Resource group
  resource_group_name = "billing-alerts-rg"
  location           = "eastus"
  
  # Budget configuration
  budget_name       = "monthly-azure-budget"
  monthly_budget    = 10.0
  warning_threshold = 5.0
  currency          = "USD"
  
  # Notification channels
  email_addresses = [
    "admin@example.com",
    "devops@example.com"
  ]
  
  webhook_url = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
  
  # Alert thresholds
  alert_thresholds = [
    { threshold = 50, type = "Actual" },
    { threshold = 80, type = "Actual" },
    { threshold = 100, type = "Forecasted" }
  ]
  
  # Enable anomaly detection
  enable_anomaly_alerts = true
  
  # Tags
  tags = {
    Environment = "production"
    Project     = "free-tier-monitoring"
    Owner       = "devops-team"
  }
}
```

### Minimal Example

```hcl
module "billing_alerts" {
  source = "./azure/billing-alerts"
  
  resource_group_name = "billing-rg"
  location           = "eastus"
  monthly_budget     = 10.0
  email_addresses    = ["admin@example.com"]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 3.0 |

## Prerequisites

### 1. Azure Subscription

You need an active Azure subscription. Cost Management works with:
- Pay-As-You-Go subscriptions
- Enterprise Agreements
- Microsoft Customer Agreements
- Free accounts (with limitations)

### 2. Required Permissions

The Azure credentials used must have these RBAC roles:

**For Budgets:**
- `Cost Management Reader` - View costs and budgets
- `Cost Management Contributor` - Create/modify budgets

**For Action Groups:**
- `Monitoring Contributor` - Create action groups
- `Resource Group Contributor` - For resource group operations

```hcl
# Example role assignment
resource "azurerm_role_assignment" "cost_management" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Cost Management Contributor"
  principal_id         = var.principal_id
}
```

### 3. Enable Azure Monitor

Azure Monitor must be available in your subscription (enabled by default).

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| location | Azure region for resources | `string` | n/a | yes |
| budget_name | Name of the budget | `string` | `"monthly-budget"` | no |
| monthly_budget | Monthly budget amount | `number` | `10.0` | no |
| warning_threshold | Warning threshold amount | `number` | `5.0` | no |
| currency | Currency code | `string` | `"USD"` | no |
| email_addresses | List of email addresses for alerts | `list(string)` | `[]` | no |
| webhook_url | Webhook URL for notifications | `string` | `""` | no |
| alert_thresholds | List of alert threshold configurations | `list(object)` | See defaults | no |
| enable_anomaly_alerts | Enable cost anomaly detection | `bool` | `true` | no |
| tags | Additional tags for resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| resource_group_name | Name of the resource group |
| resource_group_id | ID of the resource group |
| budget_id | ID of the Azure budget |
| budget_name | Name of the Azure budget |
| action_group_id | ID of the action group |
| action_group_name | Name of the action group |
| anomaly_alert_id | ID of the anomaly alert (if enabled) |

## How It Works

### Azure Budgets

1. **Monthly Budget**: Tracks total spending against a set amount
2. **Alert Thresholds**: Multiple threshold notifications (50%, 80%, 100%)
3. **Forecasted Alerts**: Warns when projected costs will exceed budget
4. **Actual Alerts**: Warns when actual costs exceed thresholds

### Action Groups

Action groups define notification channels:
- **Email**: Direct email notifications
- **SMS**: Text message alerts (charges may apply)
- **Webhook**: Integration with Slack, Teams, PagerDuty
- **Azure Functions**: Automated response actions
- **Logic Apps**: Complex automation workflows

### Budget Scope

Budgets can be scoped to:
- **Subscription**: Monitor entire subscription costs
- **Resource Group**: Monitor specific workloads
- **Management Group**: Enterprise-wide monitoring

## Cost Considerations

This module is **completely free**:
- ✅ Azure Cost Management: Always free
- ✅ Azure Budgets: Always free
- ✅ Action Groups: Always free for email
- ⚠️ SMS notifications: May incur charges
- ⚠️ Voice calls: May incur charges
- ✅ Webhook notifications: Always free

## Testing

After deployment, verify your alerts:

### 1. Check Resources in Azure Portal

```bash
# List budgets
az consumption budget list --subscription YOUR_SUBSCRIPTION_ID

# List action groups
az monitor action-group list --resource-group billing-alerts-rg
```

### 2. Test Action Group

```bash
# Send test notification
az monitor action-group test-notifications create \
  --resource-group billing-alerts-rg \
  --action-group billing-alerts \
  --alert-type budget \
  --contact-id "admin@example.com"
```

### 3. Monitor in Portal

- Go to Cost Management + Billing → Cost Management
- Check Budgets → Verify your budget exists
- Check Cost alerts → View triggered alerts

## Troubleshooting

### Budget Not Created

**Issue**: Budget fails to create

**Solutions**:
1. Check IAM permissions for Cost Management
2. Verify subscription type supports budgets
3. Ensure time period is in the future
4. Check for existing budgets with same name

### Alerts Not Received

**Issue**: Not receiving email notifications

**Solutions**:
1. Check spam/junk folder
2. Verify email address is correct
3. Confirm action group is linked to budget
4. Check Azure service health for issues

### Anomaly Alerts Not Working

**Issue**: Anomaly detection not triggering

**Solutions**:
1. Requires 90 days of spending history
2. Check subscription access
3. Verify feature is available in your region
4. Ensure email addresses are valid

### Budget Shows $0

**Issue**: Budget exists but shows no spending

**Solutions**:
1. Wait for Azure to process cost data (up to 24 hours)
2. Verify resources are in the budget scope
3. Check if using free tier resources (may show $0)
4. Ensure billing account has costs to report

## Best Practices

1. **Set Conservative Thresholds**: Start with low budget to catch unexpected charges
2. **Use Multiple Channels**: Configure email AND webhook for redundancy
3. **Enable Forecasted Alerts**: Get warned before exceeding budget
4. **Review Weekly**: Check Azure Cost Management regularly
5. **Tag Resources**: Use consistent tags for cost tracking
6. **Scope Appropriately**: Use resource group budgets for specific workloads
7. **Document Alerts**: Keep record of expected vs actual costs
8. **Test Notifications**: Verify action groups work before relying on them

## Integration Examples

### Slack Integration

```hcl
resource "azurerm_monitor_action_group" "slack" {
  name                = "slack-alerts"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "slack"

  webhook_receiver {
    name                    = "slack-webhook"
    service_uri             = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXX"
    use_common_alert_schema = true
  }
}
```

### Microsoft Teams Integration

```hcl
resource "azurerm_monitor_action_group" "teams" {
  name                = "teams-alerts"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "teams"

  webhook_receiver {
    name                    = "teams-webhook"
    service_uri             = "https://outlook.office.com/webhook/YOUR-TEAMS-WEBHOOK"
    use_common_alert_schema = true
  }
}
```

### Azure Function Response

```hcl
resource "azurerm_monitor_action_group" "function" {
  name                = "function-alerts"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "function"

  azure_function_receiver {
    name                     = "shutdown-function"
    function_app_resource_id = azurerm_function_app.shutdown.id
    function_name            = "shutdown-resources"
    http_trigger_url         = "https://myapp.azurewebsites.net/api/shutdown"
    use_common_alert_schema  = true
  }
}
```

## Resource Group vs Subscription Budgets

### Subscription Budget
- Monitors all resources in subscription
- Best for overall cost control
- Single source of truth

```hcl
resource "azurerm_consumption_budget_subscription" "main" {
  name            = "subscription-budget"
  subscription_id = data.azurerm_subscription.current.id
  amount          = 100
  # ...
}
```

### Resource Group Budget
- Monitors specific workloads
- More granular control
- Useful for team chargebacks

```hcl
resource "azurerm_consumption_budget_resource_group" "workload" {
  name              = "workload-budget"
  resource_group_id = azurerm_resource_group.workload.id
  amount            = 10
  # ...
}
```

## Related Modules

- [functions](../functions/) - Azure Functions within free tier
- [cosmos-db](../cosmos-db/) - Cosmos DB within free tier
- [event-grid](../event-grid/) - Event Grid within free tier
- [service-bus](../service-bus/) - Service Bus within free tier
- [notification-hubs](../notification-hubs/) - Notification Hubs within free tier

## Further Reading

- [Azure Cost Management](https://docs.microsoft.com/azure/cost-management-billing/)
- [Azure Budgets](https://docs.microsoft.com/azure/cost-management-billing/costs/tutorial-acm-create-budgets)
- [Action Groups](https://docs.microsoft.com/azure/azure-monitor/alerts/action-groups)
- [Cost Anomaly Alerts](https://docs.microsoft.com/azure/cost-management-billing/understand/analyze-unexpected-charges)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## Support

Found a bug or have a feature request? [Open an issue](https://github.com/lstasi/taf/issues)

---

**Remember**: Always deploy this module first! 🛡️
