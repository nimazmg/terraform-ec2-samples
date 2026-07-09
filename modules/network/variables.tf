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
  description = "Availability zone for the subnet."
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
