# Oracle Cloud Compute (Always Free) Documentation

**Current Phase**: Documentation

This document describes OCI Compute instances and how to use them within the always-free tier limits.

## 🎯 Always Free Limits

Oracle Cloud Compute is part of the OCI **always-free tier** (not limited to 30-day trial):

### AMD-Based Instances (x86)
- **2× VM.Standard.E2.1.Micro** instances (perpetually free)
  - 1/8 OCPU each
  - 1 GB RAM each
  - No time limit: These limits never expire

### ARM-Based Instances (Ampere A1)
- **VM.Standard.A1.Flex** up to the following totals (perpetually free):
  - **4 OCPUs** total across all A1 instances
  - **24 GB RAM** total across all A1 instances
  - Flexible sizing: e.g., 1×4 OCPU/24 GB, or 2×2 OCPU/12 GB, or 4×1 OCPU/6 GB
  - No time limit: These limits never expire

### Included Storage
- **2 Boot Volumes** (included with always-free compute instances)
- **200 GB total Block Volume storage** (always free, shared across boot and block volumes)
- **5 Volume Backups** (always free)

### Why the A1.Flex Is Exceptional

The Ampere A1.Flex is one of the best always-free compute offerings in the cloud industry:
- 4 OCPUs (Ampere ARM processors) — equivalent to 4 vCPUs
- 24 GB RAM — enough to run substantial workloads
- ARM architecture is excellent for Linux workloads, Docker, and modern applications
- Great for running databases, web servers, containers (Podman/Docker), CI/CD agents

## ⚠️ What Causes Charges

You will incur charges if you:
- ❌ Create more than 2 VM.Standard.E2.1.Micro instances
- ❌ Exceed 4 OCPUs or 24 GB RAM total for A1.Flex instances
- ❌ Use any shape other than E2.1.Micro or A1.Flex (e.g., VM.Standard3.Flex, BM.* shapes)
- ❌ Use more than 200 GB of Block Volume storage total
- ❌ Keep more than 5 volume backups
- ❌ Use GPU instances (always paid)
- ❌ Use HPC or DenseIO instances (always paid)

## 🏗️ Use Cases Within Free Tier

### AMD E2.1.Micro (1/8 OCPU, 1 GB RAM) — Excellent For
- ✅ **Static web servers**: nginx or Caddy serving static content
- ✅ **Lightweight APIs**: Small REST APIs with low memory usage
- ✅ **Monitoring agents**: Prometheus node exporters, CloudWatch agents
- ✅ **Jump hosts / bastion servers**: SSH access point for private resources
- ✅ **Scheduled scripts**: Cron jobs and automation tasks
- ✅ **VPN endpoints**: WireGuard or OpenVPN for personal use

### ARM A1.Flex (up to 4 OCPUs, 24 GB RAM) — Excellent For
- ✅ **Full web application stack**: nginx + app server + small database
- ✅ **Container workloads**: Docker or Podman containers
- ✅ **Kubernetes cluster**: k3s or MicroK8s single-node cluster
- ✅ **Development environments**: Full IDE server or GitHub Actions runner
- ✅ **Home lab services**: Self-hosted tools (Gitea, Nextcloud, etc.)
- ✅ **Machine learning inference**: Small model serving with ARM optimizations
- ✅ **CI/CD agents**: Build and test pipeline runners

### Consider Alternatives For
- ⚠️ **Windows workloads**: Windows images are not available on always-free shapes
- ⚠️ **x86-specific binaries**: A1.Flex requires ARM64-compatible software
- ⚠️ **Very high CPU bursting**: E2.1.Micro has limited burst capacity (1/8 OCPU)
- ⚠️ **High IOPS workloads**: Consider the 200 GB Block Volume limit
- ⚠️ **GPU requirements**: No GPU available in always-free tier

## 🎨 Architecture Patterns

### Pattern 1: Web Server + Autonomous Database
```
Internet
    ↓
Load Balancer (free: 10 Mbps)
    ↓
A1.Flex VM (4 OCPUs, 24 GB — nginx + app)
    ↓
Autonomous Database (free: 1 OCPU, 20 GB ATP)
```
**Use case**: Full web application stack
**Cost**: Free within limits

### Pattern 2: Microservices with Docker
```
A1.Flex VM (Docker host)
├── Container: Frontend (nginx)
├── Container: Backend API (Node.js/Python/Go)
└── Container: Cache (Redis)
    ↓
Object Storage (20 GB free)
```
**Use case**: Containerized application stack
**Cost**: Free within limits

### Pattern 3: Personal Development Environment
```
A1.Flex VM (4 OCPUs, 24 GB)
├── VS Code Server (code-server)
├── Development tools (Git, Docker, etc.)
└── Local database (SQLite / small PostgreSQL)
```
**Use case**: Cloud development workstation
**Cost**: Free within limits

### Pattern 4: Mixed AMD + ARM Cluster
```
E2.1.Micro #1 (monitoring / jump host)
E2.1.Micro #2 (reverse proxy / load balancer)
    ↓
A1.Flex (main workload — 4 OCPUs, 24 GB RAM)
```
**Use case**: Multi-instance always-free cluster
**Cost**: Free within limits

## 🔧 Configuration Best Practices

### Choosing the Right Shape

```hcl
# AMD Micro — for lightweight workloads
locals {
  amd_shape = "VM.Standard.E2.1.Micro"
  arm_shape = "VM.Standard.A1.Flex"
}

# A1.Flex — flexible ARM compute (use the full free allowance)
resource "oci_core_instance" "arm_instance" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 4   # Max free: 4 OCPUs total
    memory_in_gbs = 24  # Max free: 24 GB total
  }

  # ...
}
```

### Storage Configuration (Always Free)

```hcl
resource "oci_core_instance" "free_instance" {
  # ...

  source_details {
    source_type             = "image"
    source_id               = var.image_id
    boot_volume_size_in_gbs = 50  # Part of 200 GB total allowance
  }
}

# Additional block volume (within 200 GB total)
resource "oci_core_volume" "extra_storage" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "extra-storage"
  size_in_gbs         = 50  # Keep total under 200 GB
}
```

### Network Configuration

```hcl
# Public IP (ephemeral — always free)
resource "oci_core_instance" "public_instance" {
  # ...

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = true   # Ephemeral public IP is free
  }
}

# Note: Reserved public IPs may have charges when not attached
```

### Monitoring Configuration

```hcl
# OCI Monitoring is always free
# Access instance metrics via OCI Console or API:
# - CPU utilization
# - Memory utilization
# - Disk I/O
# - Network throughput
```

## 📊 Performance Characteristics

### VM.Standard.E2.1.Micro
| Characteristic | Value |
|----------------|-------|
| **OCPUs** | 1/8 (shared) |
| **RAM** | 1 GB |
| **Network Bandwidth** | Up to 480 Mbps |
| **Local Storage** | Boot volume (50 GB recommended) |
| **Architecture** | x86_64 (AMD) |
| **Best For** | Lightweight services, monitoring agents |

### VM.Standard.A1.Flex (Max Free Config)
| Characteristic | Value |
|----------------|-------|
| **OCPUs** | 4 (ARM Ampere) |
| **RAM** | 24 GB |
| **Network Bandwidth** | Up to 4 Gbps |
| **Local Storage** | Boot volume (up to 200 GB total) |
| **Architecture** | aarch64 (ARM64) |
| **Best For** | Substantial workloads, containers, full stacks |

## 🖥️ Supported Operating Systems

Both AMD and ARM shapes support these OS images (always free):
- **Oracle Linux** 7, 8, 9 (recommended for OCI integration)
- **Ubuntu** 20.04, 22.04, 24.04 (ARM64 for A1.Flex)
- **CentOS Stream** (ARM64 available)
- **Debian** (ARM64 available)

**Note**: Windows Server is not available on always-free shapes.

## 🔒 Security Best Practices

1. **Use SSH key authentication** — Never use password authentication:
```hcl
resource "oci_core_instance" "secure_instance" {
  # ...
  metadata = {
    ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
  }
}
```

2. **Restrict Security List ingress** — Only open necessary ports:
```hcl
# Allow SSH from specific IP only
ingress_security_rules {
  protocol = "6"  # TCP
  source   = "YOUR_IP/32"
  tcp_options {
    min = 22
    max = 22
  }
}
```

3. **Use OCI Vault** for secrets (20 key versions free)
4. **Enable OS Management** for patch management (always free)
5. **Use compartments** to isolate production resources

## 📈 Free Tier Monitoring

### Key Metrics to Watch

Using OCI Monitoring (always free):

```hcl
# Example: CPU alarm for E2.1.Micro
resource "oci_monitoring_alarm" "high_cpu" {
  compartment_id        = var.compartment_id
  display_name          = "high-cpu-alarm"
  destinations          = [oci_ons_notification_topic.alerts.id]
  is_enabled            = true
  metric_compartment_id = var.compartment_id
  namespace             = "oci_computeagent"
  query                 = "CpuUtilization[5m].mean() > 80"
  severity              = "WARNING"
}
```

### OCI Metrics to Monitor
- `CpuUtilization` — CPU usage percentage
- `MemoryUtilization` — RAM usage percentage
- `DiskBytesRead` / `DiskBytesWritten` — Disk I/O
- `NetworksBytesIn` / `NetworksBytesOut` — Network traffic

## 🛡️ Staying Within Free Tier

1. **Count instances**: Max 2 E2.1.Micro + A1.Flex within 4 OCPU/24 GB total
2. **Track block storage**: Sum all boot + block volumes, keep under 200 GB
3. **Monitor network egress**: Watch 10 TB/month limit
4. **Use billing-alerts**: Deploy the billing-alerts module first
5. **Terminate unused instances**: Free tier resources stay free only when within limits
6. **Use ARM for maximum value**: A1.Flex gives 24 GB RAM for free — use it!

## 🧪 Example Configurations

### Minimal ARM Instance (Always Free)
```hcl
resource "oci_core_instance" "arm_free" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  display_name        = "arm-free-instance"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.ubuntu_arm.images[0].id
    boot_volume_size_in_gbs = 50
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public_subnet.id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
    user_data           = base64encode(file("${path.module}/cloud-init.yaml"))
  }

  freeform_tags = {
    FreeTier = "true"
    Shape    = "A1.Flex"
  }
}
```

### AMD Micro Instance (Always Free)
```hcl
resource "oci_core_instance" "amd_micro" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  display_name        = "amd-micro-instance"
  shape               = "VM.Standard.E2.1.Micro"

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.oracle_linux_amd.images[0].id
    boot_volume_size_in_gbs = 47  # Default for E2.1.Micro
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public_subnet.id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
  }

  freeform_tags = {
    FreeTier = "true"
    Shape    = "E2.1.Micro"
  }
}
```

## 🔗 Related Resources

### OCI Documentation
- [Always Free Compute](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm)
- [VM.Standard.A1.Flex](https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm#flexible__a1flex)
- [OCI Compute Service](https://docs.oracle.com/en-us/iaas/Content/Compute/home.htm)
- [OCI Block Volumes](https://docs.oracle.com/en-us/iaas/Content/Block/home.htm)

### TAF Modules
- [billing-alerts](../billing-alerts/) - Monitor Compute costs
- [autonomous-db](../autonomous-db/) - Always-free database for your app
- [networking](../networking/) - VCN and Load Balancer setup
- [object-storage](../object-storage/) - Always-free object storage
- [functions](../functions/) - Serverless compute alternative

## 📝 Implementation Checklist

When deploying always-free Compute instances:

- [ ] Deploy billing-alerts module first
- [ ] Count existing E2.1.Micro instances (max 2 total)
- [ ] Calculate total A1.Flex OCPU/RAM (max 4 OCPU, 24 GB)
- [ ] Calculate total Block Volume storage (max 200 GB)
- [ ] Use SSH key authentication (not passwords)
- [ ] Configure Security Lists with minimal ingress rules
- [ ] Enable OCI Monitoring alarms for CPU/memory
- [ ] Configure auto-recovery for instance stability
- [ ] Tag resources with FreeTier = "true"
- [ ] Test SSH access after deployment
- [ ] Verify instance is accessible and running
- [ ] Monitor for first week

## 💡 Tips for Staying Free

1. **Use A1.Flex for workloads**: ARM has better price-performance for always-free
2. **Use E2.1.Micro for lightweight services**: Monitoring, jump hosts, proxies
3. **Boot volumes count toward 200 GB**: Plan your storage allocation
4. **ARM is compatible**: Most Linux software has ARM64 builds
5. **Ephemeral public IP is free**: Reserved IPs may have charges when unattached
6. **10 TB egress is generous**: Monitor but rarely an issue for hobby projects
7. **Use OCI Monitoring**: Free metrics and alarms to track resource usage

## 📞 Support

- [TAF Issues](https://github.com/lstasi/taf/issues)
- [OCI Support](https://www.oracle.com/support/)
- [OCI Community Forum](https://community.oracle.com/tech/cloud/categories/oracle-cloud-infrastructure)
- [OCI A1.Flex Availability](https://cloudharmony.com/status-for-oracle)

---

**Remember**: Always deploy [billing-alerts](../billing-alerts/) first! 🛡️
