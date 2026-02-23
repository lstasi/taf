# OCI Networking (Always Free) Documentation

**Current Phase**: Documentation

This document describes OCI Networking resources and how to use them within the always-free tier limits.

## 🎯 Always Free Limits

OCI Networking is part of the OCI **always-free tier** (not limited to 30-day trial):

### Virtual Cloud Network (VCN)
- **2 VCNs** per region (perpetually free)
- **Subnets, Route Tables, Security Lists, Internet Gateways**: All free to create within VCN limits
- **Service Gateway**: Always free (access OCI services without internet routing)
- **NAT Gateway**: Always free (outbound internet access for private subnets)
- **Local Peering Gateway**: Always free (peer VCNs within region)

### Load Balancer
- **1 flexible load balancer** with **10 Mbps bandwidth** (perpetually free)
- Supports HTTP, HTTPS, TCP protocols

### Data Transfer
- **10 TB/month outbound data transfer** to internet (perpetually free, aggregate across all OCI services)
- **Unlimited inbound** data transfer (always free)
- **Inter-region data transfer**: Limited free amount, then charged

### Other Networking
- **OCI DNS**: 1 hosted zone, 1M DNS queries/month (always free)
- **OCI Bastion**: 5 sessions per bastion (always free)

## ⚠️ What Causes Charges

You will incur charges if you:
- ❌ Exceed 10 TB/month outbound data transfer
- ❌ Use more than 1 flexible load balancer or use non-free bandwidth shapes
- ❌ Use DRG (Dynamic Routing Gateway) cross-region attachments (paid)
- ❌ Use FastConnect (dedicated connectivity — paid)
- ❌ Use Site-to-Site VPN beyond included free hours
- ❌ Use reserved public IPs when not attached to running instances
- ❌ Transfer data between OCI regions beyond free allowances

## 🏗️ Use Cases Within Free Tier

### VCN and Subnets — Excellent For
- ✅ **Public/private subnet separation**: Isolate internet-facing from backend resources
- ✅ **Security List management**: Control inbound/outbound traffic
- ✅ **Multiple availability domains**: Spread resources across ADs
- ✅ **Service Gateway**: Private access to Object Storage, Autonomous DB
- ✅ **NAT Gateway**: Outbound internet for private instances
- ✅ **Internet Gateway**: Inbound/outbound for public resources

### Load Balancer (10 Mbps) — Excellent For
- ✅ **HTTP/HTTPS distribution**: Distribute traffic across compute instances
- ✅ **SSL termination**: Offload SSL/TLS to the load balancer
- ✅ **Health checks**: Monitor backend instance availability
- ✅ **Session persistence**: Sticky sessions for stateful apps
- ✅ **Path-based routing**: Route `/api/*` and `/web/*` to different backends

### Consider Alternatives For
- ⚠️ **High-bandwidth applications**: 10 Mbps limit for the free load balancer
- ⚠️ **Very high egress traffic**: 10 TB/month is generous but finite
- ⚠️ **Multi-region redundancy**: Cross-region data transfer costs extra
- ⚠️ **Dedicated connectivity**: FastConnect is not in always-free tier

## 🎨 Architecture Patterns

### Pattern 1: Standard 3-Tier Architecture
```
Internet
    ↓
Internet Gateway (free)
    ↓
Public Subnet
├── Load Balancer (10 Mbps, free)
└── Bastion Server (E2.1.Micro, free)
    ↓
Private Subnet
├── Application Servers (A1.Flex, free)
└── NAT Gateway (free — for outbound calls)
    ↓
Private Subnet (Database)
└── Autonomous Database (private endpoint, free)
```
**Use case**: Production-grade web application on always-free resources
**Cost**: Free within limits

### Pattern 2: Single Public Subnet (Simple)
```
Internet
    ↓
Internet Gateway (free)
    ↓
Public Subnet
├── A1.Flex Instance (web + app, free)
└── E2.1.Micro Instance (monitoring, free)
```
**Use case**: Simple web application or development environment
**Cost**: Free within limits

### Pattern 3: Load Balanced Web Tier
```
Internet
    ↓
Load Balancer (10 Mbps, free)
    ↓
[Backend Set]
├── A1.Flex VM #1 (up to 2 OCPU, 12 GB)
└── A1.Flex VM #2 (up to 2 OCPU, 12 GB)
    ↓
Service Gateway (free)
    ↓
Object Storage / Autonomous Database
```
**Use case**: High-availability web tier using the total A1.Flex free allowance
**Cost**: Free within limits

### Pattern 4: Secure Private Architecture
```
Internet → NAT Gateway (outbound only)
    ↓
VCN
├── Public Subnet
│   └── OCI Bastion (5 sessions, free)
└── Private Subnet
    ├── A1.Flex (app server — no public IP)
    └── Autonomous DB (private endpoint)
        ↓
Service Gateway → OCI Services (Object Storage, etc.)
```
**Use case**: Maximum security — no direct public access to resources
**Cost**: Free within limits

## 🔧 Configuration Best Practices

### VCN Setup
```hcl
resource "oci_core_vcn" "main_vcn" {
  compartment_id = var.compartment_id
  display_name   = "main-vcn"
  cidr_block     = "10.0.0.0/16"
  dns_label      = "mainvcn"

  freeform_tags = {
    FreeTier = "true"
  }
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_id
  display_name   = "internet-gateway"
  vcn_id         = oci_core_vcn.main_vcn.id
  enabled        = true
}

resource "oci_core_nat_gateway" "nat" {
  compartment_id = var.compartment_id
  display_name   = "nat-gateway"
  vcn_id         = oci_core_vcn.main_vcn.id
}

resource "oci_core_service_gateway" "svc_gw" {
  compartment_id = var.compartment_id
  display_name   = "service-gateway"
  vcn_id         = oci_core_vcn.main_vcn.id

  services {
    service_id = data.oci_core_services.all_oci_services.services[0].id
  }
}
```

### Public and Private Subnets
```hcl
# Public subnet
resource "oci_core_subnet" "public_subnet" {
  compartment_id    = var.compartment_id
  display_name      = "public-subnet"
  vcn_id            = oci_core_vcn.main_vcn.id
  cidr_block        = "10.0.1.0/24"
  dns_label         = "public"
  route_table_id    = oci_core_route_table.public_rt.id
  security_list_ids = [oci_core_security_list.public_sl.id]

  # Public subnet — instances can have public IPs
  prohibit_public_ip_on_vnic = false
}

# Private subnet
resource "oci_core_subnet" "private_subnet" {
  compartment_id    = var.compartment_id
  display_name      = "private-subnet"
  vcn_id            = oci_core_vcn.main_vcn.id
  cidr_block        = "10.0.2.0/24"
  dns_label         = "private"
  route_table_id    = oci_core_route_table.private_rt.id
  security_list_ids = [oci_core_security_list.private_sl.id]

  # Private subnet — no public IPs
  prohibit_public_ip_on_vnic = true
}
```

### Always-Free Load Balancer
```hcl
resource "oci_load_balancer_load_balancer" "free_lb" {
  compartment_id = var.compartment_id
  display_name   = "free-load-balancer"
  shape          = "flexible"
  subnet_ids     = [oci_core_subnet.public_subnet.id]

  # Always-free: flexible shape, minimum 10 Mbps
  shape_details {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 10  # Keep at 10 Mbps for always-free
  }

  is_private = false

  freeform_tags = {
    FreeTier = "true"
  }
}

resource "oci_load_balancer_backend_set" "app_backend_set" {
  load_balancer_id = oci_load_balancer_load_balancer.free_lb.id
  name             = "app-backend-set"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol            = "HTTP"
    port                = 80
    url_path            = "/health"
    interval_ms         = 10000
    timeout_in_millis   = 3000
    retries             = 3
  }
}

resource "oci_load_balancer_listener" "http_listener" {
  load_balancer_id         = oci_load_balancer_load_balancer.free_lb.id
  name                     = "http-listener"
  default_backend_set_name = oci_load_balancer_backend_set.app_backend_set.name
  port                     = 80
  protocol                 = "HTTP"
}
```

### Security Lists (Firewall Rules)
```hcl
resource "oci_core_security_list" "public_sl" {
  compartment_id = var.compartment_id
  display_name   = "public-security-list"
  vcn_id         = oci_core_vcn.main_vcn.id

  # Allow SSH from specific IP
  ingress_security_rules {
    protocol  = "6"  # TCP
    source    = "${var.my_ip}/32"
    stateless = false
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Allow HTTP from anywhere
  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = false
    tcp_options {
      min = 80
      max = 80
    }
  }

  # Allow HTTPS from anywhere
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
}
```

## 📊 Networking Limits Reference

| Resource | Free Limit | Per |
|----------|-----------|-----|
| **VCNs** | 2 | Per region |
| **Subnets** | 10 per VCN | — |
| **Internet Gateways** | 1 per VCN | — |
| **NAT Gateways** | 1 per VCN | — |
| **Service Gateways** | 1 per VCN | — |
| **Load Balancers** | 1 (10 Mbps) | Per tenancy |
| **Outbound Data Transfer** | 10 TB/month | Per tenancy |
| **Public IPs (ephemeral)** | Included with instance | — |
| **Reserved Public IPs** | 2 | Per region |
| **OCI DNS** | 1 zone, 1M queries/month | — |
| **OCI Bastion** | 5 sessions | Per bastion |

## 🔒 Security Best Practices

1. **Use Security Lists and NSGs** to restrict traffic:
   - Security Lists: Subnet-level firewall rules
   - Network Security Groups (NSGs): Resource-level firewall rules

2. **Never open 0.0.0.0/0 for SSH** — Use specific IPs or OCI Bastion

3. **Use private subnets for databases** — Autonomous DB with private endpoint

4. **Enable VCN Flow Logs** for traffic analysis:
```hcl
resource "oci_logging_log" "vcn_flow_log" {
  display_name       = "vcn-flow-logs"
  log_group_id       = oci_logging_log_group.vcn_logs.id
  log_type           = "SERVICE"
  is_enabled         = true
  retention_duration = 30

  configuration {
    source {
      category    = "all"
      resource    = oci_core_subnet.public_subnet.id
      service     = "flowlogs"
      source_type = "OCISERVICE"
    }
    compartment_id = var.compartment_id
  }
}
```

5. **Use OCI Bastion** for SSH access instead of public IPs on instances

6. **Enable WAF** (Web Application Firewall) — available on load balancer

## 📈 Free Tier Monitoring

### Monitor Network Egress

```hcl
# Monitor outbound data transfer (warn at 8 TB = 80% of 10 TB)
resource "oci_monitoring_alarm" "egress_warning" {
  compartment_id        = var.compartment_id
  display_name          = "network-egress-warning"
  destinations          = [oci_ons_notification_topic.alerts.id]
  is_enabled            = true
  metric_compartment_id = var.compartment_id
  namespace             = "oci_vcn"
  query                 = "VnicFromNetworkBytes[1d].sum() > 8589934592000"  # 8 TB in bytes
  severity              = "WARNING"
}
```

### OCI CLI to Check Limits
```bash
# Check VCN quota
oci limits resource-availability get \
  --compartment-id <tenancy_ocid> \
  --service-name vcn \
  --limit-name vcn-count

# Check load balancer quota
oci limits resource-availability get \
  --compartment-id <tenancy_ocid> \
  --service-name load-balancing \
  --limit-name lb-100mbps-count
```

## 🛡️ Staying Within Free Tier

1. **Keep load balancer at 10 Mbps**: `maximum_bandwidth_in_mbps = 10`
2. **Monitor 10 TB egress**: Alert at 80% (8 TB)
3. **Use Service Gateway**: Avoid internet routing for OCI-to-OCI traffic
4. **Avoid inter-region transfers**: Data stays in one region to avoid charges
5. **Release unused reserved IPs**: Unattached reserved IPs may cost
6. **Use NAT Gateway**: Private instances use shared NAT (free)

## 🔗 Related Resources

### OCI Documentation
- [Always Free Networking](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm)
- [OCI VCN Overview](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/overview.htm)
- [OCI Load Balancing](https://docs.oracle.com/en-us/iaas/Content/Balance/home.htm)
- [OCI Network Firewall](https://docs.oracle.com/en-us/iaas/Content/network-firewall/home.htm)
- [OCI Bastion](https://docs.oracle.com/en-us/iaas/Content/Bastion/home.htm)

### TAF Modules
- [billing-alerts](../billing-alerts/) - Monitor network costs
- [compute](../compute/) - Compute instances in VCN
- [autonomous-db](../autonomous-db/) - Private database endpoints
- [object-storage](../object-storage/) - Service Gateway access
- [functions](../functions/) - Functions in VCN subnets

## 📝 Implementation Checklist

When deploying always-free Networking resources:

- [ ] Deploy billing-alerts module first
- [ ] Plan IP address ranges (CIDR blocks) before creating VCNs
- [ ] Create public and private subnets based on security requirements
- [ ] Configure Internet Gateway for public subnet
- [ ] Configure NAT Gateway for private subnet outbound
- [ ] Configure Service Gateway for OCI service access
- [ ] Create Security Lists with minimal required rules (deny by default)
- [ ] Create Load Balancer with 10 Mbps flexible shape
- [ ] Set up backend sets and health checks for load balancer
- [ ] Configure Route Tables to direct traffic appropriately
- [ ] Set up OCI Monitoring alarm for egress (8 TB warning)
- [ ] Tag resources with FreeTier = "true"
- [ ] Test connectivity end-to-end
- [ ] Enable VCN Flow Logs for traffic visibility

## 💡 Tips for Staying Free

1. **10 Mbps free LB is sufficient**: Most hobby projects barely use this
2. **10 TB egress is very generous**: Rarely exceeded for non-production use
3. **Use Service Gateway for OCI traffic**: Free and faster than internet routing
4. **NAT Gateway saves resources**: Private instances don't need public IPs
5. **OCI Bastion is more secure**: Use instead of bastion host VM
6. **Ephemeral IPs are free**: Use these for compute instances
7. **Reserved IPs**: Unattached reserved IPs may incur small charges

## 📞 Support

- [TAF Issues](https://github.com/lstasi/taf/issues)
- [OCI Support](https://www.oracle.com/support/)
- [OCI Networking Documentation](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/overview.htm)
- [OCI Community Forum](https://community.oracle.com/tech/cloud/categories/oracle-cloud-infrastructure)

---

**Remember**: Always deploy [billing-alerts](../billing-alerts/) first! 🛡️
