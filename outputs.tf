output "alb_dns_name" {
  description = "DNS name of the application load balancer."
  value       = module.load_balancer.dns_name
}

output "application_url" {
  description = "HTTP URL for the application."
  value       = "http://${module.load_balancer.dns_name}:${var.application.listener_port}"
}

output "vpc_id" {
  description = "ID of the VPC."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs keyed by the configured subnet names."
  value       = module.network.public_subnet_ids
}

output "security_group_ids" {
  description = "Security group IDs used by the load balancer, instances, and EFS."
  value = {
    load_balancer = module.alb_security_group.id
    application   = module.application_security_group.id
    efs           = module.efs.security_group_id
  }
}

output "instance_ids" {
  description = "IDs of the EC2 instances."
  value       = module.compute.instance_ids
}

output "instance_private_ips" {
  description = "Private IP addresses of the EC2 instances."
  value       = module.compute.private_ips
}

output "instance_public_ips" {
  description = "Public IP addresses of the EC2 instances, when enabled."
  value       = module.compute.public_ips
}

output "efs" {
  description = "EFS file system details."
  value = {
    id       = module.efs.id
    dns_name = module.efs.dns_name
  }
}

output "private_key_path" {
  description = "Local private-key path when Terraform creates the SSH key."
  value       = module.ssh_key.private_key_filename
}
