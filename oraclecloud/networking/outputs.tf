output "vcn_id" {
  description = "OCID of the VCN"
  value       = oci_core_vcn.main.id
}

output "vcn_cidr" {
  description = "CIDR block of the VCN"
  value       = oci_core_vcn.main.cidr_block
}

output "public_subnet_id" {
  description = "OCID of the public subnet"
  value       = oci_core_subnet.public.id
}

output "private_subnet_id" {
  description = "OCID of the private subnet"
  value       = oci_core_subnet.private.id
}

output "internet_gateway_id" {
  description = "OCID of the Internet Gateway"
  value       = oci_core_internet_gateway.igw.id
}

output "nat_gateway_id" {
  description = "OCID of the NAT Gateway"
  value       = oci_core_nat_gateway.nat.id
}

output "service_gateway_id" {
  description = "OCID of the Service Gateway"
  value       = oci_core_service_gateway.svc_gw.id
}

output "load_balancer_id" {
  description = "OCID of the always-free load balancer (empty if not created)"
  value       = var.create_load_balancer ? oci_load_balancer_load_balancer.free_lb[0].id : ""
}

output "load_balancer_ip_addresses" {
  description = "IP addresses of the load balancer (empty if not created)"
  value       = var.create_load_balancer ? oci_load_balancer_load_balancer.free_lb[0].ip_address_details : []
}
