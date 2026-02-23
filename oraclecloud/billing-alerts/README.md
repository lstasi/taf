# Oracle Cloud Billing Alerts Documentation

**⚠️ CRITICAL: Always configure billing protection FIRST before deploying any Oracle Cloud resources!**

**Current Phase**: Documentation

This document describes strategies and patterns for monitoring Oracle Cloud costs when using always-free resources. While always-free resources should not incur charges within their limits, billing protection is essential to catch misconfigurations or accidental usage of non-free resources.

## Why Billing Protection Matters

Even when using only always-free resources:
- Misconfigurations can deploy paid resource shapes
- Exceeding always-free limits incurs charges
- Accidental deployments during trials can be costly
- Early detection prevents bill shock after the free trial period

## Always-Free OCI Monitoring Resources

### OCI Monitoring (Always Free)
- **500 million ingestion datapoints/month** (always free)
- **1 billion retrieval datapoints/month** (always free)

### OCI Notifications (Always Free)
- **1 million+ delivery/month** (email, HTTPS, PagerDuty, Slack — always free within limits)

### OCI Budgets (Always Free)
- **Unlimited budgets** are free to create
- Budget alerts trigger at configurable thresholds

## Recommended Billing Protection Strategy

### 1. OCI Budget Alerts (Always Free)

```hcl
module "billing_alerts" {
  source = "./oraclecloud/billing-alerts"

  # Compartment configuration
  tenancy_id     = var.tenancy_ocid
  compartment_id = var.compartment_id

  # Alert configuration
  budget_name       = "always-free-budget"
  monthly_threshold = 10.0
  warning_threshold = 5.0
  currency          = "USD"

  # Notification channels
  email_address  = "alerts@example.com"
  https_endpoint = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

  # Tags
  freeform_tags = {
    Environment = "free-tier"
    Project     = "taf"
    Owner       = "admin"
  }
}
```

### Minimal Example

```hcl
module "billing_alerts" {
  source = "./oraclecloud/billing-alerts"

  tenancy_id        = var.tenancy_ocid
  monthly_threshold = 10.0
  email_address     = "admin@example.com"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| oci | ~> 6.0 |

## Prerequisites

### 1. Enable Notifications in OCI Console

To receive billing alerts:

1. Sign in to OCI Console
2. Navigate to **Budgets** under **Billing & Cost Management**
3. Create a budget with your desired threshold
4. Configure alert rules and notification topics
5. Subscribe to the notification topic via email

### 2. Create a Notification Topic

OCI Notifications requires a **topic** and **subscriptions**:

```hcl
resource "oci_ons_notification_topic" "billing_topic" {
  compartment_id = var.compartment_id
  name           = "billing-alerts-topic"

  freeform_tags = {
    FreeTier = "true"
  }
}

resource "oci_ons_subscription" "email_subscription" {
  compartment_id = var.compartment_id
  topic_id       = oci_ons_notification_topic.billing_topic.id
  endpoint       = var.email_address
  protocol       = "EMAIL"
}
```

### 3. IAM Policies

The OCI credentials used must have these policies:

```
Allow group <GroupName> to manage usage-budgets in tenancy
Allow group <GroupName> to manage ons-topics in compartment <CompartmentName>
Allow group <GroupName> to manage ons-subscriptions in compartment <CompartmentName>
Allow group <GroupName> to read metrics in compartment <CompartmentName>
Allow group <GroupName> to manage alarms in compartment <CompartmentName>
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tenancy_id | OCID of the OCI tenancy | `string` | — | yes |
| compartment_id | OCID of the compartment for notifications | `string` | — | yes |
| budget_name | Name of the OCI Budget | `string` | `"always-free-budget"` | no |
| monthly_threshold | Monthly cost threshold in USD | `number` | `10.0` | no |
| warning_threshold | Warning threshold (lower than monthly_threshold). Set to 0 to disable | `number` | `5.0` | no |
| currency | Currency code for billing alerts | `string` | `"USD"` | no |
| email_address | Email address for alerts. Leave empty to skip | `string` | `""` | no |
| https_endpoint | HTTPS webhook URL (e.g., Slack). Leave empty to skip | `string` | `""` | no |
| freeform_tags | Freeform tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| budget_id | OCID of the OCI Budget |
| budget_name | Name of the OCI Budget |
| notification_topic_id | OCID of the Notifications topic |
| notification_topic_name | Name of the Notifications topic |
| alarm_id | OCID of the OCI Monitoring alarm (if created) |

## How It Works

### OCI Budgets

OCI Budgets track spending at the tenancy or compartment level:

1. **Budget Definition**: Monthly cost limit with an amount threshold
2. **Alert Rules**: Triggers when actual or forecast spending reaches a percentage of the budget
3. **Notification Integration**: Sends alerts via OCI Notifications topics

### OCI Monitoring Alarms

For more granular control, OCI Monitoring alarms complement budgets:

1. **Metrics**: Track resource-specific usage metrics
2. **Alarm Conditions**: Define thresholds for metric values
3. **Notification Topics**: Route alerts to subscribed endpoints

### OCI Notifications

Notification topics and subscriptions handle delivery:
- **Email**: Requires email confirmation (check inbox/spam)
- **HTTPS**: Webhook for Slack, PagerDuty, custom endpoints
- **PagerDuty**: Native PagerDuty integration
- **Slack**: Direct Slack channel integration

## Email Confirmation

After deploying notification subscriptions:

1. Check your email inbox (and spam folder)
2. Look for "Oracle Cloud Infrastructure Notifications" email
3. Click the confirmation link to activate the subscription
4. You'll start receiving alerts once confirmed

## Budget Alert Configuration

OCI budget alerts support two trigger types:

```hcl
# Alert when ACTUAL spending reaches 80% of budget
resource "oci_budget_alert_rule" "actual_alert" {
  budget_id      = oci_budget_budget.monthly_budget.id
  type           = "ACTUAL"
  threshold      = 80
  threshold_type = "PERCENTAGE"
  recipients     = var.email_address
  description    = "Alert when actual spending reaches 80% of budget"
}

# Alert when FORECAST spending reaches 90% of budget
resource "oci_budget_alert_rule" "forecast_alert" {
  budget_id      = oci_budget_budget.monthly_budget.id
  type           = "FORECAST"
  threshold      = 90
  threshold_type = "PERCENTAGE"
  recipients     = var.email_address
  description    = "Alert when forecast spending reaches 90% of budget"
}
```

## Testing

After deployment, test your alerts:

### 1. Check Resources

```bash
# Verify budget exists
oci budgets budget list --compartment-id <tenancy_ocid>

# Check notification topic
oci ons topic list --compartment-id <compartment_ocid>

# List subscriptions
oci ons subscription list --compartment-id <compartment_ocid>
```

### 2. Test Notification Topic

```bash
# Manually publish test message
oci ons message publish \
  --topic-id <topic_ocid> \
  --body "Test billing alert from TAF" \
  --title "Test Alert"
```

### 3. Monitor in Console

- Go to OCI Console → Billing & Cost Management → Budgets
- Go to OCI Console → Monitoring → Alarms
- Go to OCI Console → Application Integration → Notifications

## Cost Considerations

This module is **completely free** within OCI always-free tier:
- ✅ OCI Budgets: Unlimited budgets (always free)
- ✅ OCI Notifications: 1M+ deliveries/month (always free)
- ✅ OCI Monitoring: 500M datapoints/month (always free)
- ✅ Email notifications: Included in Notifications free tier

## Troubleshooting

### Budget Not Triggering

**Issue**: Budget alert doesn't trigger even when costs exceed threshold

**Solutions**:
1. Wait up to 24 hours (budget evaluation period)
2. Verify the email subscription is confirmed
3. Check the notification topic has active subscriptions
4. Ensure the alert rule threshold is correctly configured

### Email Not Received

**Issue**: Not receiving email notifications

**Solutions**:
1. Check spam/junk folder
2. Confirm the OCI Notifications subscription (check email for confirmation link)
3. Verify email address is correct in the subscription
4. Check subscription status in OCI Console → Notifications

### Authentication Error

**Issue**: Terraform provider authentication fails

**Solutions**:
1. Verify `~/.oci/config` file has correct OCID values
2. Check that the API key fingerprint matches the uploaded public key
3. Ensure the private key file path is correct and readable
4. Validate the tenancy OCID and user OCID are correct

## Best Practices

1. **Set Conservative Thresholds**: Set `monthly_threshold` well below your actual limit (e.g., $5 for always-free)
2. **Use Warning Threshold**: Enable `warning_threshold` at 50% for early warning
3. **Enable Multiple Channels**: Configure email AND webhook for redundancy
4. **Monitor the Console**: Check OCI Cost Analysis dashboard weekly
5. **Test Notifications**: Send test messages to verify configuration
6. **Tag Resources**: Use freeform tags on all resources for cost attribution
7. **Review Always-Free Usage**: Monitor Limits, Quotas and Usage regularly

## Integration Examples

### Slack Webhook

```hcl
module "billing_alerts" {
  source = "./oraclecloud/billing-alerts"

  tenancy_id        = var.tenancy_ocid
  compartment_id    = var.compartment_id
  email_address     = "team@example.com"
  https_endpoint    = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXX"
  monthly_threshold = 10.0
}
```

### PagerDuty Integration

Use PagerDuty's HTTPS endpoint as `https_endpoint`.

## Related Modules

- [compute](../compute/) - Always-free Compute instances
- [autonomous-db](../autonomous-db/) - Always-free Autonomous Database
- [object-storage](../object-storage/) - Always-free Object Storage
- [functions](../functions/) - Always-free Oracle Functions
- [networking](../networking/) - Always-free VCN and Load Balancer

## Further Reading

- [OCI Free Tier](https://www.oracle.com/cloud/free/)
- [OCI Budgets](https://docs.oracle.com/en-us/iaas/Content/Billing/Concepts/budgetsoverview.htm)
- [OCI Notifications](https://docs.oracle.com/en-us/iaas/Content/Notification/home.htm)
- [OCI Monitoring](https://docs.oracle.com/en-us/iaas/Content/Monitoring/home.htm)
- [Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)

## Support

Found a bug or have a feature request? [Open an issue](https://github.com/lstasi/taf/issues)

---

**Remember**: Always deploy this module first! 🛡️
