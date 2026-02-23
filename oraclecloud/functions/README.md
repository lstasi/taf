# Oracle Functions (Always Free) Documentation

**Current Phase**: Documentation

This document describes Oracle Functions and how to use it within the always-free tier limits.

## 🎯 Always Free Limits

Oracle Functions is part of the OCI **always-free tier** (not limited to 30-day trial):

- **2 million function invocations/month** (perpetually free)
- **400,000 GB-seconds of compute** per month (perpetually free)
- **No time limit**: These limits never expire

### What are GB-seconds?

GB-seconds is a measure of function execution time multiplied by memory allocation:
- **1 GB-second** = 1 function running for 1 second with 1 GB memory
- **400,000 GB-seconds** examples:
  - 400,000 executions × 1 second × 1 GB memory
  - 800,000 executions × 0.5 seconds × 1 GB memory
  - 3,200,000 executions × 0.125 seconds × 1 GB memory

### Practical Examples

**Example 1: Simple API handler (128 MB)**
- Memory: 128 MB (0.125 GB)
- Duration: 100 ms (0.1 seconds)
- Monthly invocations: 2M (free tier limit)
- GB-seconds used: 2M × 0.1 × 0.125 = 25,000 GB-seconds
- **Result**: Well within free tier ✅

**Example 2: Data processing function (512 MB)**
- Memory: 512 MB (0.5 GB)
- Duration: 500 ms (0.5 seconds)
- Monthly invocations: 200,000
- GB-seconds used: 200K × 0.5 × 0.5 = 50,000 GB-seconds
- **Result**: Well within free tier ✅

## ⚠️ What Causes Charges

You will incur charges if you:
- ❌ Exceed 2M invocations/month
- ❌ Exceed 400,000 GB-seconds/month
- ❌ Use OCI API Gateway beyond the 1M free calls/month
- ❌ Store large container images (uses Object Storage quota)
- ❌ Use Functions with VCN endpoints (network costs may apply)

## 🏗️ Use Cases Within Free Tier

### Excellent Use Cases
- ✅ **REST API backends**: HTTP functions triggered via API Gateway (1M calls/month free)
- ✅ **Scheduled tasks**: Functions triggered by OCI Events or Scheduled Jobs
- ✅ **Event-driven processing**: Object Storage triggers (object created/deleted)
- ✅ **Webhooks**: GitHub, Slack, payment provider webhooks
- ✅ **Data transformation**: ETL pipelines with Autonomous Database
- ✅ **Image processing**: Thumbnail generation on Object Storage upload
- ✅ **Notifications**: Triggered alerts via OCI Notifications
- ✅ **Automation**: OCI resource management automation

### Consider Alternatives For
- ⚠️ **Long-running jobs**: Functions timeout at 5 minutes; use Compute for longer tasks
- ⚠️ **Very high traffic**: Monitor invocation count against 2M/month limit
- ⚠️ **Stateful applications**: Functions are stateless; use Autonomous DB for state
- ⚠️ **Heavy computation**: Memory-intensive tasks; check GB-seconds usage

## 🎨 Architecture Patterns

### Pattern 1: API Gateway + Functions + Autonomous DB
```
Client
    ↓
OCI API Gateway (1M calls/month free)
    ↓
Oracle Functions (2M invocations/month free)
    ↓
Autonomous Transaction Processing (1 OCPU, 20 GB free)
```
**Use case**: REST API with Oracle database backend
**Cost**: Free within limits

### Pattern 2: Object Storage + Functions (Event-Driven)
```
User uploads file
    ↓
OCI Object Storage (20 GB free)
    ↓ (Object Created Event)
OCI Events Service
    ↓
Oracle Functions (processes file)
    ↓
Autonomous Database (stores metadata)
```
**Use case**: File upload processing pipeline
**Cost**: Free within limits

### Pattern 3: Scheduled Functions
```
OCI Scheduler (Scheduled Job — always free)
    ↓
Oracle Functions (2M invocations/month free)
    ↓
OCI Notifications (report/alert via email)
```
**Use case**: Daily report generation, health checks
**Cost**: Free within limits

### Pattern 4: Webhook Handler
```
External Service (GitHub, Stripe, etc.)
    ↓
Oracle Functions (HTTPS endpoint)
    ↓
OCI Notifications + Autonomous DB
```
**Use case**: Process webhooks from external services
**Cost**: Free within limits

## 🔧 Configuration Best Practices

### Function Application Setup
```hcl
resource "oci_functions_application" "free_app" {
  compartment_id = var.compartment_id
  display_name   = "free-tier-app"

  # Subnet for function execution (use existing VCN subnet)
  subnet_ids = [oci_core_subnet.function_subnet.id]

  # Optional: VCN configuration for private access
  # config = {
  #   "DB_CONNECTION_STRING" = var.db_connection_string
  # }

  freeform_tags = {
    FreeTier = "true"
    Purpose  = "api-backend"
  }
}
```

### Function Definition
```hcl
resource "oci_functions_function" "api_handler" {
  application_id = oci_functions_application.free_app.id
  display_name   = "api-handler"
  image          = "${var.region}.ocir.io/${data.oci_objectstorage_namespace.ns.namespace}/${var.repo_name}:latest"

  # Memory configuration (always-free: 400K GB-seconds total)
  memory_in_mbs = "256"  # 256 MB — balance of performance and GB-second usage

  # Timeout (max 300 seconds = 5 minutes)
  timeout_in_seconds = 30

  config = {
    LOG_LEVEL    = "INFO"
    DB_URL       = var.db_connection_url
  }

  freeform_tags = {
    FreeTier = "true"
  }
}
```

### API Gateway Integration
```hcl
resource "oci_apigateway_gateway" "free_gateway" {
  compartment_id = var.compartment_id
  display_name   = "free-api-gateway"
  endpoint_type  = "PUBLIC"
  subnet_id      = oci_core_subnet.public_subnet.id

  freeform_tags = {
    FreeTier = "true"
  }
}

resource "oci_apigateway_deployment" "api_deployment" {
  compartment_id = var.compartment_id
  display_name   = "free-api-deployment"
  gateway_id     = oci_apigateway_gateway.free_gateway.id
  path_prefix    = "/v1"

  specification {
    routes {
      path    = "/hello"
      methods = ["GET", "POST"]

      backend {
        type        = "ORACLE_FUNCTIONS_BACKEND"
        function_id = oci_functions_function.api_handler.id
      }
    }
  }
}
```

### Object Storage Trigger (Event-Driven)
```hcl
resource "oci_events_rule" "object_created" {
  compartment_id = var.compartment_id
  display_name   = "trigger-on-object-upload"
  is_enabled     = true

  condition = jsonencode({
    eventType = ["com.oraclecloud.objectstorage.createobject"]
    data = {
      additionalDetails = {
        bucketName = [oci_objectstorage_bucket.uploads.name]
      }
    }
  })

  actions {
    actions {
      action_type = "FAAS"
      function_id = oci_functions_function.api_handler.id
      is_enabled  = true
    }
  }
}
```

## 📊 Memory and Duration Optimization

### Memory Configuration

| Memory | GB-seconds per 1K calls (1s avg) | When to Use |
|--------|-----------------------------------|-------------|
| **128 MB** | 128 | Simple webhooks, event handlers |
| **256 MB** | 256 | JSON processing, DB queries |
| **512 MB** | 512 | Image processing, API calls |
| **1024 MB** | 1024 | Data transformation, ML inference |

**Tip**: Higher memory = more CPU power. Fast functions with more memory may use fewer GB-seconds.

### Duration Optimization
1. **Cold starts**: Use lightweight runtimes; avoid heavy frameworks
2. **Reuse connections**: Initialize DB connections outside the handler
3. **Code efficiency**: Minimize external calls and processing time
4. **Appropriate timeouts**: Set realistic timeouts (not maximum 300s)

## 🔒 Security Best Practices

1. **Use Resource Principal** for OCI service access:
```
Allow dynamic-group <FunctionsDynamicGroup> to manage objects in compartment <CompartmentName>
Allow dynamic-group <FunctionsDynamicGroup> to use autonomous-databases in compartment <CompartmentName>
```

2. **Never hardcode secrets** in function configuration:
```hcl
# Use OCI Vault for secrets
config = {
  DB_SECRET_OCID = oci_vault_secret.db_password.id
}
```

3. **Validate function inputs** to prevent injection attacks
4. **Use HTTPS only** for API Gateway endpoints
5. **Restrict CORS** on API Gateway to known origins
6. **Enable OCI Audit** for function invocation tracking

## 📈 Free Tier Monitoring

### OCI Monitoring for Functions

```hcl
# Alarm: high invocation count (approaching 2M/month limit)
resource "oci_monitoring_alarm" "function_invocations" {
  compartment_id        = var.compartment_id
  display_name          = "function-invocation-warning"
  destinations          = [oci_ons_notification_topic.alerts.id]
  is_enabled            = true
  metric_compartment_id = var.compartment_id
  namespace             = "oci_faas"
  query                 = "FunctionInvocationCount[1d].sum() > 60000"  # ~90% of 2M/month daily
  severity              = "WARNING"
}

# Alarm: high error rate
resource "oci_monitoring_alarm" "function_errors" {
  compartment_id        = var.compartment_id
  display_name          = "function-error-rate"
  destinations          = [oci_ons_notification_topic.alerts.id]
  is_enabled            = true
  metric_compartment_id = var.compartment_id
  namespace             = "oci_faas"
  query                 = "FunctionExecutionErrors[5m].sum() > 10"
  severity              = "CRITICAL"
}
```

### Key OCI Metrics for Functions
- `FunctionInvocationCount` — Total invocations (watch 2M/month)
- `FunctionExecutionDuration` — Average execution time
- `FunctionExecutionErrors` — Error count
- `FunctionThrottledCount` — Throttle events
- `FunctionMemoryUsed` — Actual memory consumed

## 🛡️ Staying Within Free Tier

1. **Track invocations**: Set alarm at 1.8M/month (90% of 2M limit)
2. **Calculate GB-seconds**: Monitor actual memory × duration usage
3. **Optimize cold starts**: Keep functions warm with low-traffic triggers if needed
4. **Use efficient runtimes**: Go and Java native have fast cold starts
5. **Set sensible timeouts**: Don't use 300s for fast functions
6. **Deploy billing-alerts**: Always monitor overall OCI spending

## 🔗 Related Resources

### OCI Documentation
- [Always Free Functions](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm)
- [Oracle Functions Overview](https://docs.oracle.com/en-us/iaas/Content/Functions/home.htm)
- [OCI API Gateway](https://docs.oracle.com/en-us/iaas/Content/APIGateway/home.htm)
- [Fn Project](https://fnproject.io/) (open-source Functions framework)

### TAF Modules
- [billing-alerts](../billing-alerts/) - Monitor function costs
- [autonomous-db](../autonomous-db/) - Always-free database for functions
- [object-storage](../object-storage/) - Object Storage for function triggers
- [networking](../networking/) - VCN for private function access
- [compute](../compute/) - Compute alternative for long-running tasks

## 📝 Implementation Checklist

When deploying always-free Oracle Functions:

- [ ] Deploy billing-alerts module first
- [ ] Set up OCI Container Registry for function images
- [ ] Create Function Application with appropriate VCN subnet
- [ ] Configure Dynamic Group for Resource Principal authentication
- [ ] Set memory to minimum needed (start with 256 MB)
- [ ] Set realistic timeout (not maximum 300s)
- [ ] Set up OCI Monitoring alarms for invocations and errors
- [ ] Configure API Gateway if HTTP access needed
- [ ] Test function invocation from OCI Console
- [ ] Set up CI/CD to build and push function images
- [ ] Tag resources with FreeTier = "true"
- [ ] Monitor usage for first week
- [ ] Optimize based on actual metrics

## 💡 Tips for Staying Free

1. **2M invocations is generous**: Most hobby projects stay well under
2. **Use 128-256 MB memory**: Right-size to minimize GB-seconds
3. **Avoid unnecessary invocations**: Don't poll; use event-driven patterns
4. **Reuse containers**: OCI Functions reuses containers — initialize once
5. **Use Resource Principal**: No credential management needed
6. **Monitor weekly**: Check FunctionInvocationCount in OCI Console
7. **Event-driven is efficient**: OCI Events + Functions is fully free-tier friendly

## 📞 Support

- [TAF Issues](https://github.com/lstasi/taf/issues)
- [OCI Support](https://www.oracle.com/support/)
- [Oracle Functions Community](https://community.oracle.com/tech/cloud/categories/oracle-functions)
- [Fn Project Community](https://github.com/fnproject/fn)

---

**Remember**: Always deploy [billing-alerts](../billing-alerts/) first! 🛡️
