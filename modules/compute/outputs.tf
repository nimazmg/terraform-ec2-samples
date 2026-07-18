output "instance_ids" {
  description = "IDs of the EC2 instances."
  value       = aws_instance.web[*].id
}

output "private_ips" {
  description = "Private IPv4 addresses of the EC2 instances."
  value       = aws_instance.web[*].private_ip
}

output "public_ips" {
  description = "Public IPv4 addresses of the EC2 instances, when enabled."
  value       = aws_instance.web[*].public_ip
}

output "network_interface_ids" {
  description = "IDs of the primary network interfaces."
  value       = aws_instance.web[*].primary_network_interface_id
}

output "data_volume_ids" {
  description = "IDs of the optional EBS data volumes."
  value       = aws_ebs_volume.main[*].id
}
