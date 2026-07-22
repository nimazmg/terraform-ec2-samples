output "key_name" {
  description = "Name of the created or reused EC2 key pair."
  value       = var.create ? aws_key_pair.main[0].key_name : var.key_name
}

output "private_key_filename" {
  description = "Generated private-key path, or null when an existing key is reused."
  value       = var.create ? local_file.private_key[0].filename : null
}
