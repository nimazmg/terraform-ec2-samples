variable "name" {
  description = "Security group name."
  type        = string
}

variable "description" {
  description = "Security group description."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC in which to create the security group."
  type        = string
}

variable "ingress_rules" {
  description = "Inbound rules for the security group."
  type = list(object({
    description        = optional(string)
    from_port          = number
    to_port            = number
    protocol           = string
    cidr_blocks        = optional(list(string), [])
    ipv6_cidr_blocks   = optional(list(string), [])
    security_group_ids = optional(list(string), [])
    self               = optional(bool, false)
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.ingress_rules :
      rule.from_port >= -1 &&
      rule.to_port <= 65535 &&
      rule.from_port <= rule.to_port &&
      rule.from_port == floor(rule.from_port) &&
      rule.to_port == floor(rule.to_port) &&
      length(trimspace(rule.protocol)) > 0
    ])
    error_message = "Ingress rules must have a protocol and ordered, whole-number ports from -1 through 65535."
  }

  validation {
    condition = alltrue([
      for rule in var.ingress_rules :
      rule.self ||
      length(rule.cidr_blocks) > 0 ||
      length(rule.ipv6_cidr_blocks) > 0 ||
      length(rule.security_group_ids) > 0
    ])
    error_message = "Every ingress rule must define at least one source."
  }

  validation {
    condition = alltrue(flatten([
      for rule in var.ingress_rules : [
        for cidr in rule.cidr_blocks : can(cidrnetmask(cidr))
      ]
    ]))
    error_message = "Ingress IPv4 sources must be valid CIDR blocks."
  }

  validation {
    condition = alltrue(flatten([
      for rule in var.ingress_rules : [
        for cidr in rule.ipv6_cidr_blocks :
        can(cidrhost(cidr, 0)) && length(regexall(":", cidr)) > 0
      ]
    ]))
    error_message = "Ingress IPv6 sources must be valid CIDR blocks."
  }
}

variable "egress_rules" {
  description = "Outbound rules for the security group."
  type = list(object({
    description        = optional(string)
    from_port          = number
    to_port            = number
    protocol           = string
    cidr_blocks        = optional(list(string), [])
    ipv6_cidr_blocks   = optional(list(string), [])
    security_group_ids = optional(list(string), [])
    self               = optional(bool, false)
  }))

  default = [
    {
      description = "Allow all outbound IPv4 traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  validation {
    condition = alltrue([
      for rule in var.egress_rules :
      rule.from_port >= -1 &&
      rule.to_port <= 65535 &&
      rule.from_port <= rule.to_port &&
      rule.from_port == floor(rule.from_port) &&
      rule.to_port == floor(rule.to_port) &&
      length(trimspace(rule.protocol)) > 0
    ])
    error_message = "Egress rules must have a protocol and ordered, whole-number ports from -1 through 65535."
  }

  validation {
    condition = alltrue([
      for rule in var.egress_rules :
      rule.self ||
      length(rule.cidr_blocks) > 0 ||
      length(rule.ipv6_cidr_blocks) > 0 ||
      length(rule.security_group_ids) > 0
    ])
    error_message = "Every egress rule must define at least one destination."
  }

  validation {
    condition = alltrue(flatten([
      for rule in var.egress_rules : [
        for cidr in rule.cidr_blocks : can(cidrnetmask(cidr))
      ]
    ]))
    error_message = "Egress IPv4 destinations must be valid CIDR blocks."
  }

  validation {
    condition = alltrue(flatten([
      for rule in var.egress_rules : [
        for cidr in rule.ipv6_cidr_blocks :
        can(cidrhost(cidr, 0)) && length(regexall(":", cidr)) > 0
      ]
    ]))
    error_message = "Egress IPv6 destinations must be valid CIDR blocks."
  }
}

variable "tags" {
  description = "Additional tags for the security group."
  type        = map(string)
  default     = {}
}
