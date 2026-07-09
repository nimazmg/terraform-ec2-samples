output "instance_ids" {
  description = "IDs of the created EC2 instances."
  value       = aws_instance.web[*].id
}

output "network_interface_ids" {
  description = "IDs of the created ENIs."
  value       = aws_network_interface.eni[*].id
}
