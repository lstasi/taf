# Oracle Cloud Compute

This module creates one OCI compute instance on an always-free shape and can attach monitoring alarms when a notification topic is provided.

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

## Always-Free Caveats

- The module restricts shapes to `VM.Standard.A1.Flex` and `VM.Standard.E2.1.Micro`.
- A1 Flex OCPU and memory allowances are tenancy-wide totals.
- Boot volume sizing counts toward the tenancy-wide 200 GB block storage allowance.

## Current Gaps

- The module cannot see or limit compute or block storage already consumed elsewhere in the tenancy.
- You must supply a valid image OCID from your chosen region and availability domain.
