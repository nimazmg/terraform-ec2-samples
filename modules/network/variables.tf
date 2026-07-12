variable "name_prefix" {
  description = "Name prefix for network resources."
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC."
  type        = bool
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC."
  type        = bool
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet."
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the primary subnet."
  type        = string
}

variable "secondary_availability_zone" {
  description = "Availability zone for the secondary subnet."
  type        = string
}

variable "map_public_ip_on_launch" {
  description = "Whether instances launched in the subnet receive public IPs by default."
  type        = bool
}

variable "default_route_cidr_block" {
  description = "Destination CIDR block for the default route."
  type        = string
}
# target group variables
variable "target_group_port" {
  description = "Port for the target group."
  type        = number
}
variable "target_group_protocol" {
  description = "Protocol for the target group."
  type        = string
}
variable "health_check_path" {
  description = "Path for the health check."
  type        = string
}
variable "health_check_interval" {
  description = "Interval for the health check."
  type        = number
}
variable "health_check_timeout" {
  description = "Timeout for the health check."
  type        = number
}
variable "health_check_healthy_threshold" {
  description = "Healthy threshold for the health check."
  type        = number
}
variable "health_check_unhealthy_threshold" {
  description = "Unhealthy threshold for the health check."
  type        = number
}
variable "health_check_matcher" {
  description = "Matcher for the health check."
  type        = string
}
variable "security_group_id" {
  description = "ID of the security group to associate with the ALB."
  type        = string
}