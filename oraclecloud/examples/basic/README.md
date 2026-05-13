# Basic OCI Always-Free Example

A minimal, deployable configuration that combines the three core TAF OCI modules:

1. **billing-alerts** — budget + spend notifications (deploy first)
2. **networking** — VCN, public/private subnets, gateways
3. **compute** — A1 Flex instance with monitoring wired to the billing topic

This example mirrors the shape used by [`openclaw_oracle`](https://github.com/lab86-work/openclaw_oracle).

## ⚠️ A1 Flex Tenancy-Wide Limit

> **OCI Always Free A1 Flex gives you 4 OCPUs and 24 GB RAM per tenancy — not per instance.**
>
> All A1 Flex instances in your tenancy share this pool. `terraform plan` always succeeds; `apply` will fail (or charge you) if the tenancy pool is already full.
>
> `billing-alerts` is deployed first precisely to catch any unexpected spend before it escalates.

## Prerequisites

- OCI CLI configured: `~/.oci/config` with a valid user key
- Terraform ≥ 1.5
- An A1 Flex-compatible OS image OCID for your region — see [OCI image listing](https://docs.oracle.com/en-us/iaas/images/) (filter: Platform Image, Shape VM.Standard.A1.Flex, e.g. Ubuntu 22.04 aarch64)
- Your operator's public SSH key

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars — fill in all required values

terraform init
terraform validate        # passes without OCI credentials
terraform plan
terraform apply
```

> **Note**: `terraform validate` uses `-backend=false` implicitly on init, so it works without credentials. Running `plan` and `apply` requires valid OCI credentials.

## Variables

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `tenancy_ocid` | ✅ | — | OCI tenancy OCID |
| `user_ocid` | ✅ | — | OCI user OCID |
| `fingerprint` | ✅ | — | API key fingerprint |
| `private_key_path` | ✅ | — | Path to API key PEM |
| `region` | — | `eu-madrid-1` | OCI region |
| `compartment_ocid` | ✅ | — | Compartment OCID |
| `availability_domain` | ✅ | — | AD name for compute |
| `image_id` | ✅ | — | aarch64 OS image OCID |
| `ssh_public_key` | ✅ | — | Operator public SSH key |
| `instance_ocpus` | — | `1` | OCPUs (tenancy max: 4 total) |
| `instance_memory_in_gbs` | — | `6` | RAM in GB (tenancy max: 24 GB total) |
| `instance_display_name` | — | `openclaw-vm` | VM display name |
| `ssh_ingress_cidr` | ✅ | — | Operator IP/32 for SSH (never 0.0.0.0/0) |
| `alert_email` | — | `""` | Email for billing alerts |
| `monthly_threshold` | — | `10.0` | Budget threshold in USD |

## Outputs

| Output | Description |
| --- | --- |
| `instance_public_ip` | Public IP to SSH to and point DNS at |
| `instance_id` | OCID of the VM |
| `vcn_id` | OCID of the VCN |
| `public_subnet_id` | OCID of the public subnet |
| `budget_id` | OCID of the billing budget |
| `notification_topic_id` | OCID of the billing notifications topic |

## Free-Tier Assumptions

- One A1 Flex VM ≤ 4 OCPUs / 24 GB RAM total in tenancy
- One VCN (free), one public + one private subnet (free), one Internet Gateway (free), one NAT Gateway (free)
- Load balancer disabled (`create_load_balancer = false`) to avoid consuming the single always-free LB slot
- Boot volume ≤ 200 GB total block storage in tenancy
- OCI Notifications topic (free)
- OCI Budget (free)
