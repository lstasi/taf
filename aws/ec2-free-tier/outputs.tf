output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.free_tier.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.free_tier.arn
}

output "instance_state" {
  description = "State of the EC2 instance"
  value       = aws_instance.free_tier.instance_state
}

output "public_ip" {
  description = "Public IP address of the instance"
  value       = aws_instance.free_tier.public_ip
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.free_tier.private_ip
}

output "public_dns" {
  description = "Public DNS name of the instance"
  value       = aws_instance.free_tier.public_dns
}

output "private_dns" {
  description = "Private DNS name of the instance"
  value       = aws_instance.free_tier.private_dns
}

output "elastic_ip" {
  description = "Elastic IP address (if assigned)"
  value       = var.assign_elastic_ip ? aws_eip.instance[0].public_ip : null
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.instance.id
}

output "security_group_name" {
  description = "Name of the security group"
  value       = aws_security_group.instance.name
}

output "ssh_command" {
  description = "SSH command to connect to the instance (if key_name is provided)"
  value       = var.key_name != "" ? "ssh -i ~/.ssh/${var.key_name}.pem ec2-user@${aws_instance.free_tier.public_ip}" : "No SSH key configured"
}

output "instance_hours_per_month" {
  description = "Approximate instance hours per month (for cost tracking)"
  value       = "~730 hours (1 instance running continuously)"
}
