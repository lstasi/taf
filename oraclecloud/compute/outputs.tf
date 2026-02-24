output "instance_id" {
  description = "OCID of the compute instance"
  value       = oci_core_instance.main.id
}

output "instance_state" {
  description = "State of the compute instance"
  value       = oci_core_instance.main.state
}

output "public_ip" {
  description = "Public IP address of the instance (empty if no public IP assigned)"
  value       = oci_core_instance.main.public_ip
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = oci_core_instance.main.private_ip
}

output "boot_volume_id" {
  description = "OCID of the boot volume"
  value       = oci_core_instance.main.boot_volume_id
}

output "shape" {
  description = "Shape of the compute instance"
  value       = oci_core_instance.main.shape
}
