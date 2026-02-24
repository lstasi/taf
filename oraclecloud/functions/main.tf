locals {
  merged_tags = merge({ FreeTier = "true" }, var.freeform_tags)
}

# ---------------------------------------------------------------------------
# Function Application
# ---------------------------------------------------------------------------

resource "oci_functions_application" "main" {
  compartment_id = var.compartment_id
  display_name   = var.application_display_name
  subnet_ids     = [var.subnet_id]
  config         = var.application_config

  freeform_tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# Functions
# ---------------------------------------------------------------------------

resource "oci_functions_function" "functions" {
  for_each = var.functions

  application_id     = oci_functions_application.main.id
  display_name       = each.key
  image              = each.value.image
  memory_in_mbs      = tostring(each.value.memory_in_mbs)
  timeout_in_seconds = each.value.timeout_in_seconds
  config             = each.value.config

  freeform_tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# API Gateway (optional, 1M calls/month always free)
# ---------------------------------------------------------------------------

resource "oci_apigateway_gateway" "main" {
  count = var.create_api_gateway ? 1 : 0

  compartment_id = var.compartment_id
  display_name   = var.api_gateway_display_name
  endpoint_type  = "PUBLIC"
  subnet_id      = var.api_gateway_subnet_id

  freeform_tags = local.merged_tags
}

resource "oci_apigateway_deployment" "main" {
  count = var.create_api_gateway && length(var.api_routes) > 0 ? 1 : 0

  compartment_id = var.compartment_id
  display_name   = "${var.api_gateway_display_name}-deployment"
  gateway_id     = oci_apigateway_gateway.main[0].id
  path_prefix    = "/v1"

  specification {
    dynamic "routes" {
      for_each = var.api_routes
      content {
        path    = routes.key
        methods = routes.value.methods

        backend {
          type        = "ORACLE_FUNCTIONS_BACKEND"
          function_id = oci_functions_function.functions[routes.value.function_key].id
        }
      }
    }
  }

  freeform_tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# Monitoring alarms (created when notification_topic_id is provided)
# ---------------------------------------------------------------------------

# Warn when daily invocations approach 90% of the monthly free limit (2M/month ≈ 60k/day)
resource "oci_monitoring_alarm" "invocation_warning" {
  count = var.notification_topic_id != "" ? 1 : 0

  compartment_id        = var.compartment_id
  display_name          = "${var.application_display_name}-invocation-warning"
  destinations          = [var.notification_topic_id]
  is_enabled            = true
  metric_compartment_id = var.compartment_id
  namespace             = "oci_faas"
  query                 = "FunctionInvocationCount[1d].sum() > 60000"
  severity              = "WARNING"

  freeform_tags = local.merged_tags
}

resource "oci_monitoring_alarm" "error_rate" {
  count = var.notification_topic_id != "" ? 1 : 0

  compartment_id        = var.compartment_id
  display_name          = "${var.application_display_name}-error-rate"
  destinations          = [var.notification_topic_id]
  is_enabled            = true
  metric_compartment_id = var.compartment_id
  namespace             = "oci_faas"
  query                 = "FunctionExecutionErrors[5m].sum() > 10"
  severity              = "CRITICAL"

  freeform_tags = local.merged_tags
}
