output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs keyed by the caller-selected subnet names."
  value       = { for key, subnet in aws_subnet.public : key => subnet.id }
}

output "public_subnet_arns" {
  description = "Public subnet ARNs keyed by the caller-selected subnet names."
  value       = { for key, subnet in aws_subnet.public : key => subnet.arn }
}

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = aws_route_table.public.id
}
