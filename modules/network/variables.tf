variable "name_prefix" {
  description = "Name prefix for network resources."
  type        = string
}

variable "vpc_cidr_block" {
  description = "IPv4 CIDR block for the VPC."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr_block))
    error_message = "vpc_cidr_block must be a valid IPv4 CIDR block."
  }
}

variable "public_subnets" {
  description = "Public subnets keyed by stable, caller-selected names."
  type = map(object({
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = optional(bool, true)
  }))

  validation {
    condition     = length(var.public_subnets) > 0
    error_message = "At least one public subnet is required."
  }

  validation {
    condition = alltrue([
      for subnet in values(var.public_subnets) :
      can(cidrnetmask(subnet.cidr_block))
    ])
    error_message = "Every public subnet must use a valid IPv4 CIDR block."
  }

  validation {
    condition = (
      length(distinct([
        for subnet in values(var.public_subnets) : subnet.cidr_block
      ])) == length(var.public_subnets)
    )
    error_message = "Public subnet CIDR blocks must be unique."
  }

  validation {
    condition = (
      length(distinct([
        for subnet in values(var.public_subnets) : subnet.availability_zone
      ])) == length(var.public_subnets)
    )
    error_message = "Each public subnet must use a different availability zone."
  }
}

variable "default_route_cidr_block" {
  description = "Destination CIDR block routed through the internet gateway."
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrnetmask(var.default_route_cidr_block))
    error_message = "default_route_cidr_block must be a valid IPv4 CIDR block."
  }
}

variable "tags" {
  description = "Additional tags for supported resources."
  type        = map(string)
  default     = {}
}
