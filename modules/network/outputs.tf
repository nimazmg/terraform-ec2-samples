output "vpc_id" {
  description = "ID of the created VPC."
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "ID of the created subnet."
  value       = aws_subnet.main.id
}

output "target_group_arn" {
  description = "ARN of the created target group."
  value       = aws_lb_target_group.main.arn
}

output "alb_arn" {
  description = "ARN of the created Application Load Balancer."
  value       = aws_alb.main.arn
}