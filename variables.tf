variable "aws_region" {
  description = "AWS region in which to create the stack."
  type        = string
  default     = "eu-central-1"
  nullable    = false

  validation {
    condition     = length(trimspace(var.aws_region)) > 0
    error_message = "aws_region must not be empty."
  }
}

variable "project_name" {
  description = "Short name used to identify and tag the stack."
  type        = string
  default     = "web-server"
  nullable    = false

  validation {
    condition = (
      length(var.project_name) <= 20 &&
      can(regex("^[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?$", var.project_name))
    )
    error_message = "project_name must be 1-20 letters, numbers, or hyphens and cannot start or end with a hyphen."
  }
}

variable "network" {
  description = "VPC and public subnet configuration."
  type = object({
    vpc_cidr_block           = optional(string, "10.0.0.0/16")
    default_route_cidr_block = optional(string, "0.0.0.0/0")
    public_subnets = map(object({
      cidr_block              = string
      availability_zone       = string
      map_public_ip_on_launch = optional(bool, true)
    }))
  })
  nullable = false

  validation {
    condition     = can(cidrnetmask(var.network.vpc_cidr_block))
    error_message = "network.vpc_cidr_block must be a valid IPv4 CIDR block."
  }

  validation {
    condition     = can(cidrnetmask(var.network.default_route_cidr_block))
    error_message = "network.default_route_cidr_block must be a valid IPv4 CIDR block."
  }

  validation {
    condition     = length(var.network.public_subnets) >= 2
    error_message = "network.public_subnets must define at least two subnets for the load balancer."
  }

  validation {
    condition = alltrue([
      for subnet in values(var.network.public_subnets) :
      can(cidrnetmask(subnet.cidr_block))
    ])
    error_message = "Every public subnet must have a valid IPv4 CIDR block."
  }

  validation {
    condition = (
      length(distinct([
        for subnet in values(var.network.public_subnets) : subnet.cidr_block
      ])) == length(var.network.public_subnets)
    )
    error_message = "Public subnet CIDR blocks must be unique."
  }

  validation {
    condition = (
      length(distinct([
        for subnet in values(var.network.public_subnets) : subnet.availability_zone
      ])) == length(var.network.public_subnets)
    )
    error_message = "Each public subnet must use a different availability zone."
  }
}

variable "compute" {
  description = "EC2, AMI, SSH key, and data-volume configuration."
  type = object({
    subnet_key              = optional(string, "primary")
    instance_type           = optional(string, "t2.micro")
    instance_count          = optional(number, 2)
    private_ip_start        = optional(number)
    ssh_key_name            = optional(string)
    create_ssh_key          = optional(bool, true)
    ssh_key_rsa_bits        = optional(number, 2048)
    ssh_allowed_cidr_blocks = optional(list(string), [])
    ami_id                  = optional(string)
    ami = optional(object({
      name_pattern        = optional(string, "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*")
      owners              = optional(list(string), ["099720109477"])
      architecture        = optional(string, "x86_64")
      virtualization_type = optional(string, "hvm")
    }), {})
    data_volume = optional(object({
      enabled     = optional(bool, true)
      size        = optional(number, 8)
      type        = optional(string, "gp3")
      encrypted   = optional(bool, true)
      device_name = optional(string, "/dev/sdf")
    }), {})
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(keys(var.network.public_subnets), var.compute.subnet_key)
    error_message = "compute.subnet_key must match a key in network.public_subnets."
  }

  validation {
    condition = (
      var.compute.instance_count >= 1 &&
      var.compute.instance_count == floor(var.compute.instance_count)
    )
    error_message = "compute.instance_count must be a whole number of at least 1."
  }

  validation {
    condition = (
      var.compute.private_ip_start == null ||
      (
        var.compute.private_ip_start >= 4 &&
        var.compute.private_ip_start == floor(var.compute.private_ip_start)
      )
    )
    error_message = "compute.private_ip_start must be null or a whole-number host offset of at least 4."
  }

  validation {
    condition = (
      var.compute.private_ip_start == null ||
      try(
        cidrhost(
          var.network.public_subnets[var.compute.subnet_key].cidr_block,
          var.compute.private_ip_start + var.compute.instance_count - 1
          ) != cidrhost(
          var.network.public_subnets[var.compute.subnet_key].cidr_block,
          -1
        ),
        false
      )
    )
    error_message = "The configured private IP range must fit in the selected subnet and avoid its reserved final address."
  }

  validation {
    condition     = contains(["x86_64", "arm64"], var.compute.ami.architecture)
    error_message = "compute.ami.architecture must be x86_64 or arm64."
  }

  validation {
    condition = (
      var.compute.ami_id == null ||
      can(regex("^ami-[0-9a-fA-F]+$", var.compute.ami_id))
    )
    error_message = "compute.ami_id must be null or a valid AMI ID."
  }

  validation {
    condition     = length(var.compute.ami.owners) > 0
    error_message = "compute.ami.owners must contain at least one AWS account ID or owner alias."
  }

  validation {
    condition = (
      var.compute.data_volume.size >= 1 &&
      var.compute.data_volume.size == floor(var.compute.data_volume.size) &&
      length(trimspace(var.compute.data_volume.type)) > 0
    )
    error_message = "compute.data_volume must have a positive whole-number size and a non-empty type."
  }

  validation {
    condition = (
      var.compute.ssh_key_rsa_bits >= 2048 &&
      var.compute.ssh_key_rsa_bits == floor(var.compute.ssh_key_rsa_bits)
    )
    error_message = "compute.ssh_key_rsa_bits must be a whole number of at least 2048."
  }

  validation {
    condition = (
      var.compute.create_ssh_key ||
      try(length(trimspace(var.compute.ssh_key_name)) > 0, false)
    )
    error_message = "compute.ssh_key_name must be set when create_ssh_key is false."
  }

  validation {
    condition = alltrue([
      for cidr in var.compute.ssh_allowed_cidr_blocks :
      try(cidrnetmask(cidr) != "0.0.0.0", false)
    ])
    error_message = "SSH sources must be valid IPv4 CIDRs and cannot be 0.0.0.0/0."
  }
}

variable "application" {
  description = "Load balancer, application port, and health-check configuration."
  type = object({
    listener_port       = optional(number, 80)
    target_port         = optional(number, 80)
    allowed_cidr_blocks = optional(list(string), ["0.0.0.0/0"])
    health_check = optional(object({
      path                = optional(string, "/")
      interval            = optional(number, 30)
      timeout             = optional(number, 5)
      healthy_threshold   = optional(number, 2)
      unhealthy_threshold = optional(number, 2)
      matcher             = optional(string, "200-299")
    }), {})
  })
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      var.application.listener_port >= 1,
      var.application.listener_port <= 65535,
      var.application.listener_port == floor(var.application.listener_port),
      var.application.target_port >= 1,
      var.application.target_port <= 65535,
      var.application.target_port == floor(var.application.target_port)
    ])
    error_message = "Application ports must be whole numbers between 1 and 65535."
  }

  validation {
    condition = alltrue([
      for cidr in var.application.allowed_cidr_blocks : can(cidrnetmask(cidr))
    ])
    error_message = "Every application.allowed_cidr_blocks entry must be a valid IPv4 CIDR block."
  }

  validation {
    condition = (
      var.application.health_check.interval >= 5 &&
      var.application.health_check.interval <= 300 &&
      var.application.health_check.interval == floor(var.application.health_check.interval) &&
      var.application.health_check.timeout >= 2 &&
      var.application.health_check.timeout <= 120 &&
      var.application.health_check.timeout == floor(var.application.health_check.timeout) &&
      var.application.health_check.timeout < var.application.health_check.interval &&
      var.application.health_check.healthy_threshold >= 2 &&
      var.application.health_check.healthy_threshold <= 10 &&
      var.application.health_check.healthy_threshold == floor(var.application.health_check.healthy_threshold) &&
      var.application.health_check.unhealthy_threshold >= 2 &&
      var.application.health_check.unhealthy_threshold <= 10 &&
      var.application.health_check.unhealthy_threshold == floor(var.application.health_check.unhealthy_threshold)
    )
    error_message = "Health-check interval, timeout, and thresholds must be within AWS limits, with timeout shorter than interval."
  }

  validation {
    condition = (
      can(regex("^/[A-Za-z0-9._/-]*$", var.application.health_check.path)) &&
      length(regexall("\\.\\.", var.application.health_check.path)) == 0
    )
    error_message = "application.health_check.path must be a simple absolute URL path without a query string."
  }

  validation {
    condition     = can(regex("^[0-9]{3}(-[0-9]{3})?(,[0-9]{3}(-[0-9]{3})?)*$", var.application.health_check.matcher))
    error_message = "application.health_check.matcher must contain HTTP status codes or ranges such as 200-299."
  }
}

variable "tags" {
  description = "Additional tags applied to all supported AWS resources."
  type        = map(string)
  default     = {}
  nullable    = false
}
