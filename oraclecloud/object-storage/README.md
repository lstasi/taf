# Oracle Cloud Object Storage

This module creates an Object Storage bucket with optional lifecycle policy and optional monitoring alarm.

## What It Creates

- One bucket.
- An optional lifecycle policy.
- An optional monitoring alarm.

## Key Inputs

- `region` and `compartment_id`
- `bucket_name`
- `storage_tier`
- `access_type`
- `versioning`
- `enable_lifecycle_policy`, `lifecycle_archive_days`, and `lifecycle_delete_days`
- `notification_topic_id`

## Key Outputs

- `bucket_name`
- `bucket_id`
- `namespace`
- `storage_tier`
- `bucket_url`

## Example

```hcl
module "object_storage" {
  source = "./oraclecloud/object-storage"

  region         = "us-ashburn-1"
  compartment_id = var.compartment_id
  bucket_name    = "taf-static-assets"
  storage_tier   = "Standard"
  access_type    = "NoPublicAccess"
}
```

## Always-Free Caveats

- Standard storage and archive storage have separate always-free allowances.
- Public bucket access is possible if `access_type` is changed from `NoPublicAccess`.
- Versioning increases storage consumption and should be used carefully.

## Current Gaps

- No stronger validation for bucket naming beyond what OCI enforces.
- No forecast of object growth against the free storage allowance.
