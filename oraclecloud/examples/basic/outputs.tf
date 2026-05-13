output "instance_public_ip" {
  description = "Public IP of the compute instance"
  value       = module.compute.public_ip
}

output "instance_id" {
  description = "OCID of the compute instance"
  value       = module.compute.instance_id
}

output "vcn_id" {
  description = "OCID of the VCN"
  value       = module.networking.vcn_id
}

output "public_subnet_id" {
  description = "OCID of the public subnet"
  value       = module.networking.public_subnet_id
}

output "budget_id" {
  description = "OCID of the billing budget"
  value       = module.billing_alerts.budget_id
}

output "notification_topic_id" {
  description = "OCID of the billing notifications topic"
  value       = module.billing_alerts.notification_topic_id
}
