output "arn" {
  description = "ARN of the application load balancer."
  value       = aws_alb.main.arn
}

output "dns_name" {
  description = "DNS name of the application load balancer."
  value       = aws_alb.main.dns_name
}

output "zone_id" {
  description = "Canonical hosted zone ID of the application load balancer."
  value       = aws_alb.main.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group."
  value       = aws_lb_target_group.main.arn
}
