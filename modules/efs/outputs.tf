output "id" {
  description = "ID of the EFS file system."
  value       = aws_efs_file_system.main.id
}

output "arn" {
  description = "ARN of the EFS file system."
  value       = aws_efs_file_system.main.arn
}

output "dns_name" {
  description = "DNS name of the EFS file system."
  value       = aws_efs_file_system.main.dns_name
}

output "security_group_id" {
  description = "ID of the EFS security group."
  value       = aws_security_group.efs.id
}

output "mount_target_ids" {
  description = "Mount target IDs keyed by subnet name."
  value       = { for key, target in aws_efs_mount_target.main : key => target.id }
}
