locals {
  merged_tags    = merge({ FreeTier = "true" }, var.freeform_tags)
  is_flex_shape  = var.shape == "VM.Standard.A1.Flex"
}

# ---------------------------------------------------------------------------
# Compute Instance (always-free shape)
# ---------------------------------------------------------------------------

resource "oci_core_instance" "main" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = var.display_name
  shape               = var.shape

  # Flexible shape config applies only to A1.Flex
  dynamic "shape_config" {
    for_each = local.is_flex_shape ? [1] : []
    content {
      ocpus         = var.ocpus
      memory_in_gbs = var.memory_in_gbs
    }
  }

  source_details {
    source_type             = "image"
    source_id               = var.image_id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = var.assign_public_ip
  }

  metadata = merge(
    {
      ssh_authorized_keys = var.ssh_authorized_keys
    },
    var.user_data != "" ? { user_data = var.user_data } : {}
  )

  freeform_tags = merge(local.merged_tags, {
    Shape = var.shape
  })
}

# ---------------------------------------------------------------------------
# Monitoring alarms (created only when notification_topic_id is provided)
# ---------------------------------------------------------------------------

resource "oci_monitoring_alarm" "high_cpu" {
  count = var.notification_topic_id != "" ? 1 : 0

  compartment_id        = var.compartment_id
  display_name          = "${var.display_name}-high-cpu"
  destinations          = [var.notification_topic_id]
  is_enabled            = true
  metric_compartment_id = var.compartment_id
  namespace             = "oci_computeagent"
  query                 = "CpuUtilization[5m].mean() > 80"
  severity              = "WARNING"

  freeform_tags = local.merged_tags
}

resource "oci_monitoring_alarm" "high_memory" {
  count = var.notification_topic_id != "" ? 1 : 0

  compartment_id        = var.compartment_id
  display_name          = "${var.display_name}-high-memory"
  destinations          = [var.notification_topic_id]
  is_enabled            = true
  metric_compartment_id = var.compartment_id
  namespace             = "oci_computeagent"
  query                 = "MemoryUtilization[5m].mean() > 80"
  severity              = "WARNING"

  freeform_tags = local.merged_tags
}
