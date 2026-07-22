variable "name_prefix" {
  description = "Name prefix for load-balancer resources."
  type        = string

  validation {
    condition     = length(var.name_prefix) <= 20
    error_message = "name_prefix must not exceed 20 characters so generated AWS names remain valid."
  }
}

variable "vpc_id" {
  description = "ID of the VPC for the target group."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs used by the application load balancer."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "An application load balancer requires at least two subnet IDs."
  }
}

variable "security_group_ids" {
  description = "Security group IDs attached to the load balancer."
  type        = list(string)

  validation {
    condition     = length(var.security_group_ids) > 0
    error_message = "At least one security group ID is required."
  }
}

variable "internal" {
  description = "Whether the load balancer is internal."
  type        = bool
  default     = false
}

variable "listener_port" {
  description = "HTTP listener port."
  type        = number
  default     = 80

  validation {
    condition = (
      var.listener_port >= 1 &&
      var.listener_port <= 65535 &&
      var.listener_port == floor(var.listener_port)
    )
    error_message = "listener_port must be a whole number between 1 and 65535."
  }
}

variable "target_port" {
  description = "HTTP port on registered targets."
  type        = number
  default     = 80

  validation {
    condition = (
      var.target_port >= 1 &&
      var.target_port <= 65535 &&
      var.target_port == floor(var.target_port)
    )
    error_message = "target_port must be a whole number between 1 and 65535."
  }
}

variable "target_ids" {
  description = "EC2 instance IDs registered with the target group."
  type        = list(string)
  default     = []
}

variable "health_check" {
  description = "Target group health-check settings."
  type = object({
    path                = optional(string, "/")
    interval            = optional(number, 30)
    timeout             = optional(number, 5)
    healthy_threshold   = optional(number, 2)
    unhealthy_threshold = optional(number, 2)
    matcher             = optional(string, "200-299")
  })
  default = {}

  validation {
    condition = (
      var.health_check.interval >= 5 &&
      var.health_check.interval <= 300 &&
      var.health_check.interval == floor(var.health_check.interval) &&
      var.health_check.timeout >= 2 &&
      var.health_check.timeout <= 120 &&
      var.health_check.timeout == floor(var.health_check.timeout) &&
      var.health_check.timeout < var.health_check.interval &&
      var.health_check.healthy_threshold >= 2 &&
      var.health_check.healthy_threshold <= 10 &&
      var.health_check.healthy_threshold == floor(var.health_check.healthy_threshold) &&
      var.health_check.unhealthy_threshold >= 2 &&
      var.health_check.unhealthy_threshold <= 10 &&
      var.health_check.unhealthy_threshold == floor(var.health_check.unhealthy_threshold)
    )
    error_message = "Health-check settings must be within AWS limits, with timeout shorter than interval."
  }

  validation {
    condition     = can(regex("^/[A-Za-z0-9._/-]*$", var.health_check.path))
    error_message = "health_check.path must be a simple absolute URL path without a query string."
  }

  validation {
    condition     = can(regex("^[0-9]{3}(-[0-9]{3})?(,[0-9]{3}(-[0-9]{3})?)*$", var.health_check.matcher))
    error_message = "health_check.matcher must contain HTTP status codes or ranges such as 200-299."
  }
}

variable "tags" {
  description = "Additional tags for supported resources."
  type        = map(string)
  default     = {}
}
