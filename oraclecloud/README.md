# Oracle Cloud Infrastructure Always Free Modules

This directory contains the implemented OCI modules in TAF. OCI is the strongest fit for the project's goals because several always-free limits can be encoded directly in Terraform, especially for compute shapes and Autonomous Database.

## ⚠️ A1 Flex Tenancy-Wide Limit

> **The OCI Always Free A1 Flex allowance is a tenancy-wide shared pool: 4 OCPUs and 24 GB RAM total across ALL A1 Flex instances in your tenancy.**
>
> Deploying two instances (e.g., 2 OCPUs + 12 GB each) exhausts the tenancy's free allowance entirely. Terraform `plan` will succeed in both cases; `apply` will fail at capacity or incur charges if OCI adds capacity later.
>
> **Always deploy [billing-alerts](billing-alerts/README.md) first** to protect against unexpected charges.

## Implemented Modules

| Module | Status | Purpose | Main Caveat |
| --- | --- | --- | --- |
| [billing-alerts](billing-alerts/README.md) | Implemented | Budget, notifications topic, subscriptions, alert rules | Notifications do not prevent overages |
| [networking](networking/README.md) | Implemented | VCN, public and private subnets, gateways, optional load balancer | Default public ingress should be reviewed before production use |
| [compute](compute/README.md) | Implemented | Always-free OCI instance on allowed shapes | **Tenancy-wide A1 pool: 4 OCPUs / 24 GB RAM shared across all instances** |
| [autonomous-db](autonomous-db/README.md) | Implemented | Free-tier Autonomous Database | Two-database tenancy limit is external to the module |
| [object-storage](object-storage/README.md) | Implemented | Object Storage bucket, optional lifecycle, optional alarm | Public access is possible if `access_type` is opened |
| [functions](functions/README.md) | Implemented | Function application, functions, optional API Gateway, alarms | You must supply prebuilt function images |

## Recommended Order

1. Start with [billing-alerts](billing-alerts/README.md).
2. Create [networking](networking/README.md) if other modules need shared subnets.
3. Add compute, storage, database, or functions modules as needed.

See [examples/basic](examples/basic/README.md) for a complete working example that combines all three essential modules.

## Shared Caveats

- OCI always-free capacity still includes tenancy-wide limits, especially for A1 Flex OCPU, memory, and block storage totals.
- Some modules require external artifacts or lookups, such as image OCIDs for compute and container images for functions.
- The networking module ships with workable defaults, not locked-down security defaults.

## Missing Work

- CI validation and security scanning.
- Additional validation for tenancy-wide usage and naming constraints.
