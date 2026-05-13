# Oracle Cloud Compute

This module creates one OCI compute instance on an always-free shape and can attach monitoring alarms when a notification topic is provided.

## ⚠️ A1 Flex Tenancy-Wide Limit

> **OCI Always Free A1 Flex gives you a tenancy-wide shared pool of 4 OCPUs and 24 GB RAM — not 4 OCPUs per instance.**
>
> If your tenancy already has any A1 Flex instance(s), the new instance's OCPUs and memory count against the same pool. A `terraform plan` will succeed even when the tenancy is at capacity; the `apply` will fail with a capacity error or, if capacity is added later, may incur charges.
>
> **First step**: deploy the [billing-alerts](../billing-alerts/README.md) module to get notified before any unexpected spend occurs.

Total free-tier block storage is also tenancy-wide: **200 GB across all boot and block volumes**.

## What It Creates

- One compute instance.
- Optional monitoring alarms for CPU and memory usage.

## Key Inputs

- `compartment_id`, `availability_domain`, `subnet_id`, and `image_id`
- `shape`, `ocpus`, and `memory_in_gbs`
- `boot_volume_size_in_gbs`
- `assign_public_ip`
- `ssh_authorized_keys`
- `notification_topic_id`

## Key Outputs

- `instance_id`
- `instance_state`
- `public_ip`
- `private_ip`
- `boot_volume_id`
- `shape`

## Example

```hcl
module "compute" {
  source = "./oraclecloud/compute"

  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  subnet_id           = var.subnet_id
  image_id            = var.image_id
  shape               = "VM.Standard.A1.Flex"
  ocpus               = 1
  memory_in_gbs       = 6
  ssh_authorized_keys = file("~/.ssh/id_ed25519.pub")
}
```

See [examples/basic](../examples/basic/README.md) for a complete working example combining networking, compute, and billing-alerts.

## Always-Free Caveats

- The module restricts shapes to `VM.Standard.A1.Flex` and `VM.Standard.E2.1.Micro`.
- **A1 Flex OCPU (max 4) and memory (max 24 GB) are tenancy-wide totals — shared across all A1 instances in the tenancy.**
- Boot volume sizing counts toward the tenancy-wide 200 GB block storage allowance.

## Current Gaps

- The module cannot see or limit compute or block storage already consumed elsewhere in the tenancy.
- You must supply a valid image OCID from your chosen region and availability domain.
