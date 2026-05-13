# ─── Basic OCI Always-Free Example ─────────────────────────────────────────────
#
# Deploys the three essential modules in the recommended order:
#   1. billing-alerts  — spend protection (deploy first)
#   2. networking      — VCN, subnets, gateways
#   3. compute         — A1 Flex VM with monitoring wired to billing-alerts topic
#
# ⚠️  A1 Flex tenancy-wide limits: 4 OCPUs and 24 GB RAM shared across ALL
#     A1 Flex instances in the tenancy. Terraform plan succeeds regardless; apply
#     will fail or incur charges if the tenancy pool is already exhausted.

# ─── 1. Billing alerts (always deploy first) ────────────────────────────────────

module "billing_alerts" {
  source = "../../billing-alerts"

  tenancy_id        = var.tenancy_ocid
  compartment_id    = var.compartment_ocid
  monthly_threshold = var.monthly_threshold
  email_address     = var.alert_email
}

# ─── 2. Networking ──────────────────────────────────────────────────────────────

module "networking" {
  source = "../../networking"

  compartment_id        = var.compartment_ocid
  ssh_ingress_cidr      = var.ssh_ingress_cidr
  notification_topic_id = module.billing_alerts.notification_topic_id
  create_load_balancer  = false
}

# ─── 3. Compute ─────────────────────────────────────────────────────────────────

module "compute" {
  source = "../../compute"

  compartment_id        = var.compartment_ocid
  availability_domain   = var.availability_domain
  subnet_id             = module.networking.public_subnet_id
  image_id              = var.image_id
  shape                 = "VM.Standard.A1.Flex"
  ocpus                 = var.instance_ocpus
  memory_in_gbs         = var.instance_memory_in_gbs
  display_name          = var.instance_display_name
  ssh_authorized_keys   = var.ssh_public_key
  assign_public_ip      = true
  notification_topic_id = module.billing_alerts.notification_topic_id
}
