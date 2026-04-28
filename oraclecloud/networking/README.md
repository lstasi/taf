# Oracle Cloud Networking

This module creates a basic OCI network foundation with public and private subnets, core gateways, an optional always-free load balancer, and an optional egress alarm.

## What It Creates

- One VCN.
- One public subnet and one private subnet.
- Internet, NAT, and Service Gateways.
- Public and private route tables.
- Public and private security lists.
- An optional flexible public load balancer pinned to 10 Mbps.
- An optional egress alarm.

## Key Inputs

- `compartment_id`
- `vcn_cidr`, `public_subnet_cidr`, and `private_subnet_cidr`
- `vcn_display_name` and `vcn_dns_label`
- `create_load_balancer`
- `ssh_ingress_cidr`
- `notification_topic_id`

## Key Outputs

- `vcn_id`
- `public_subnet_id`
- `private_subnet_id`
- `internet_gateway_id`
- `nat_gateway_id`
- `service_gateway_id`
- `load_balancer_id`

## Example

```hcl
module "networking" {
  source = "./oraclecloud/networking"

  compartment_id    = var.compartment_id
  ssh_ingress_cidr  = "203.0.113.10/32"
  create_load_balancer = true
}
```

## Important Notes

- Review the public security list before use. The module opens HTTP and HTTPS from the internet and defaults SSH ingress to `0.0.0.0/0` unless you narrow it.
- The load balancer is public when enabled.

## Current Gaps

- Security defaults are usable, but not hardened.
- The module does not validate CIDR overlaps or broader tenancy network conventions.
