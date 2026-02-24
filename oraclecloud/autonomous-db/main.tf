locals {
  merged_tags  = merge({ FreeTier = "true" }, var.freeform_tags)
  display_name = var.display_name != "" ? var.display_name : lower(var.db_name)
}

# ---------------------------------------------------------------------------
# Autonomous Database (always-free: is_free_tier = true)
# Always-free limits: 1 OCPU, 20 GB storage, no auto-scaling
# ---------------------------------------------------------------------------

resource "oci_database_autonomous_database" "main" {
  compartment_id  = var.compartment_id
  db_name         = var.db_name
  display_name    = local.display_name
  db_workload     = var.db_workload
  admin_password  = var.admin_password

  # Always-free configuration
  is_free_tier             = true
  cpu_core_count           = 1
  data_storage_size_in_tbs = 0 # 20 GB for always-free tier
  is_dedicated             = false

  # Auto-scaling must remain disabled in the always-free tier
  is_auto_scaling_enabled = var.is_auto_scaling_enabled

  # Optional IP allowlist (leave empty to allow all)
  whitelisted_ips = length(var.whitelisted_ips) > 0 ? var.whitelisted_ips : null

  freeform_tags = merge(local.merged_tags, {
    WorkloadType = var.db_workload
  })
}

# ---------------------------------------------------------------------------
# Monitoring alarms (created only when notification_topic_id is provided)
# ---------------------------------------------------------------------------

# Warn when storage utilization exceeds 80% of the 20 GB free tier limit
resource "oci_monitoring_alarm" "storage_warning" {
  count = var.notification_topic_id != "" ? 1 : 0

  compartment_id        = var.compartment_id
  display_name          = "${local.display_name}-storage-warning"
  destinations          = [var.notification_topic_id]
  is_enabled            = true
  metric_compartment_id = var.compartment_id
  namespace             = "oci_autonomous_database"
  query                 = "StorageUtilization[1h].mean() > 80"
  severity              = "WARNING"

  freeform_tags = local.merged_tags
}

# Warn when CPU utilization exceeds 80% (1 OCPU limit)
resource "oci_monitoring_alarm" "cpu_warning" {
  count = var.notification_topic_id != "" ? 1 : 0

  compartment_id        = var.compartment_id
  display_name          = "${local.display_name}-cpu-warning"
  destinations          = [var.notification_topic_id]
  is_enabled            = true
  metric_compartment_id = var.compartment_id
  namespace             = "oci_autonomous_database"
  query                 = "CpuUtilization[5m].mean() > 80"
  severity              = "WARNING"

  freeform_tags = local.merged_tags
}
