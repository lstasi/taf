locals {
  merged_tags = merge({ FreeTier = "true" }, var.freeform_tags)
}

# OCI services data source for Service Gateway configuration
data "oci_core_services" "all" {}

locals {
  # Use the first available OCI service (all-services CIDR for Service Gateway)
  oci_service_id   = length(data.oci_core_services.all.services) > 0 ? data.oci_core_services.all.services[0].id : null
  oci_service_cidr = length(data.oci_core_services.all.services) > 0 ? data.oci_core_services.all.services[0].cidr_block : null
}

# ---------------------------------------------------------------------------
# Virtual Cloud Network
# ---------------------------------------------------------------------------

resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_id
  display_name   = var.vcn_display_name
  cidr_block     = var.vcn_cidr
  dns_label      = var.vcn_dns_label

  freeform_tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# Gateways
# ---------------------------------------------------------------------------

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_id
  display_name   = "internet-gateway"
  vcn_id         = oci_core_vcn.main.id
  enabled        = true

  freeform_tags = local.merged_tags
}

resource "oci_core_nat_gateway" "nat" {
  compartment_id = var.compartment_id
  display_name   = "nat-gateway"
  vcn_id         = oci_core_vcn.main.id

  freeform_tags = local.merged_tags
}

# Service gateway gives private access to OCI services (Object Storage, etc.)
resource "oci_core_service_gateway" "svc_gw" {
  compartment_id = var.compartment_id
  display_name   = "service-gateway"
  vcn_id         = oci_core_vcn.main.id

  services {
    service_id = local.oci_service_id
  }

  freeform_tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# Route Tables
# ---------------------------------------------------------------------------

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_id
  display_name   = "public-route-table"
  vcn_id         = oci_core_vcn.main.id

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.igw.id
  }

  freeform_tags = local.merged_tags
}

resource "oci_core_route_table" "private" {
  compartment_id = var.compartment_id
  display_name   = "private-route-table"
  vcn_id         = oci_core_vcn.main.id

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.nat.id
  }

  route_rules {
    destination       = local.oci_service_cidr
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.svc_gw.id
  }

  freeform_tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# Security Lists
# ---------------------------------------------------------------------------

resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_id
  display_name   = "public-security-list"
  vcn_id         = oci_core_vcn.main.id

  # Allow SSH inbound
  ingress_security_rules {
    protocol  = "6" # TCP
    source    = var.ssh_ingress_cidr
    stateless = false
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Allow HTTP inbound
  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = false
    tcp_options {
      min = 80
      max = 80
    }
  }

  # Allow HTTPS inbound
  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = false
    tcp_options {
      min = 443
      max = 443
    }
  }

  # Allow all outbound
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }

  freeform_tags = local.merged_tags
}

resource "oci_core_security_list" "private" {
  compartment_id = var.compartment_id
  display_name   = "private-security-list"
  vcn_id         = oci_core_vcn.main.id

  # Allow all traffic from within the VCN
  ingress_security_rules {
    protocol  = "all"
    source    = var.vcn_cidr
    stateless = false
  }

  # Allow all outbound
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }

  freeform_tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# Subnets
# ---------------------------------------------------------------------------

resource "oci_core_subnet" "public" {
  compartment_id    = var.compartment_id
  display_name      = "public-subnet"
  vcn_id            = oci_core_vcn.main.id
  cidr_block        = var.public_subnet_cidr
  dns_label         = "public"
  route_table_id    = oci_core_route_table.public.id
  security_list_ids = [oci_core_security_list.public.id]

  prohibit_public_ip_on_vnic = false

  freeform_tags = local.merged_tags
}

resource "oci_core_subnet" "private" {
  compartment_id    = var.compartment_id
  display_name      = "private-subnet"
  vcn_id            = oci_core_vcn.main.id
  cidr_block        = var.private_subnet_cidr
  dns_label         = "private"
  route_table_id    = oci_core_route_table.private.id
  security_list_ids = [oci_core_security_list.private.id]

  prohibit_public_ip_on_vnic = true

  freeform_tags = local.merged_tags
}

# ---------------------------------------------------------------------------
# Always-Free Load Balancer (10 Mbps flexible shape)
# ---------------------------------------------------------------------------

resource "oci_load_balancer_load_balancer" "free_lb" {
  count = var.create_load_balancer ? 1 : 0

  compartment_id = var.compartment_id
  display_name   = "free-load-balancer"
  shape          = "flexible"
  subnet_ids     = [oci_core_subnet.public.id]

  # Always-free: flexible shape, keep at 10 Mbps
  shape_details {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 10
  }

  is_private = false

  freeform_tags = local.merged_tags
}

resource "oci_load_balancer_backend_set" "app" {
  count = var.create_load_balancer ? 1 : 0

  load_balancer_id = oci_load_balancer_load_balancer.free_lb[0].id
  name             = "app-backend-set"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol          = "HTTP"
    port              = 80
    url_path          = "/health"
    interval_ms       = 10000
    timeout_in_millis = 3000
    retries           = 3
  }
}

resource "oci_load_balancer_listener" "http" {
  count = var.create_load_balancer ? 1 : 0

  load_balancer_id         = oci_load_balancer_load_balancer.free_lb[0].id
  name                     = "http-listener"
  default_backend_set_name = oci_load_balancer_backend_set.app[0].name
  port                     = 80
  protocol                 = "HTTP"
}

# ---------------------------------------------------------------------------
# Monitoring alarm for network egress (warn at 8 TB = 80% of 10 TB free limit)
# ---------------------------------------------------------------------------

resource "oci_monitoring_alarm" "egress_warning" {
  count = var.notification_topic_id != "" ? 1 : 0

  compartment_id        = var.compartment_id
  display_name          = "network-egress-warning"
  destinations          = [var.notification_topic_id]
  is_enabled            = true
  metric_compartment_id = var.compartment_id
  namespace             = "oci_vcn"
  # 8 TB in bytes
  query    = "VnicFromNetworkBytes[1d].sum() > 8796093022208"
  severity = "WARNING"

  freeform_tags = local.merged_tags
}
