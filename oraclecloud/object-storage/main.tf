locals {
  merged_tags = merge({ FreeTier = "true" }, var.freeform_tags)
  # Standard tier free limit: 20 GB; Archive tier free limit: 10 GB
  # Set warning at 75% of the respective limit in bytes
  storage_warning_bytes = var.storage_tier == "Standard" ? 16106127360 : 8053063680
}

# Get Object Storage namespace (required for all Object Storage operations)
data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.compartment_id
}

# ---------------------------------------------------------------------------
# Object Storage Bucket
# ---------------------------------------------------------------------------

resource "oci_objectstorage_bucket" "main" {
  compartment_id = var.compartment_id
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = var.bucket_name
  access_type    = var.access_type
  storage_tier   = var.storage_tier
  versioning     = var.versioning

  freeform_tags = merge(local.merged_tags, {
    StorageTier = var.storage_tier
  })
}

# ---------------------------------------------------------------------------
# Lifecycle Policy (optional)
# ---------------------------------------------------------------------------

resource "oci_objectstorage_object_lifecycle_policy" "main" {
  count = var.enable_lifecycle_policy ? 1 : 0

  namespace = data.oci_objectstorage_namespace.ns.namespace
  bucket    = oci_objectstorage_bucket.main.name

  # Archive old objects to reduce Standard tier usage
  dynamic "rules" {
    for_each = var.storage_tier == "Standard" ? [1] : []
    content {
      name        = "archive-old-objects"
      action      = "ARCHIVE"
      is_enabled  = true
      time_amount = var.lifecycle_archive_days
      time_unit   = "DAYS"
    }
  }

  # Delete old objects to stay within free tier limits
  dynamic "rules" {
    for_each = var.lifecycle_delete_days > 0 ? [1] : []
    content {
      name        = "delete-old-objects"
      action      = "DELETE"
      is_enabled  = true
      time_amount = var.lifecycle_delete_days
      time_unit   = "DAYS"
    }
  }
}

# ---------------------------------------------------------------------------
# Monitoring alarm for storage usage (created when notification_topic_id is provided)
# ---------------------------------------------------------------------------

resource "oci_monitoring_alarm" "storage_warning" {
  count = var.notification_topic_id != "" ? 1 : 0

  compartment_id        = var.compartment_id
  display_name          = "${var.bucket_name}-storage-warning"
  destinations          = [var.notification_topic_id]
  is_enabled            = true
  metric_compartment_id = var.compartment_id
  namespace             = "oci_objectstorage"
  # Warn at 75% of free tier limit
  query    = "StoredBytes[1d].mean() > ${local.storage_warning_bytes}"
  severity = "WARNING"

  freeform_tags = local.merged_tags
}
