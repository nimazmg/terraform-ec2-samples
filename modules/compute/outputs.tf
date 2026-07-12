output "instance_ids" {
  description = "IDs of the created EC2 instances."
  value       = aws_instance.web[*].id
}

output "network_interface_ids" {
  description = "IDs of the primary network interfaces created for the EC2 instances."
  value       = aws_instance.web[*].primary_network_interface_id
}