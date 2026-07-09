variable "name" {
  description = "Security group name."
  type        = string
}

variable "description" {
  description = "Security group description."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the security group."
  type        = string
}

variable "ingress_from_port" {
  description = "Ingress start port."
  type        = number
}

variable "ingress_to_port" {
  description = "Ingress end port."
  type        = number
}

variable "ingress_protocol" {
  description = "Ingress protocol."
  type        = string
}

variable "ingress_cidr_blocks" {
  description = "Ingress CIDR blocks."
  type        = list(string)
}

variable "egress_from_port" {
  description = "Egress start port."
  type        = number
}

variable "egress_to_port" {
  description = "Egress end port."
  type        = number
}

variable "egress_protocol" {
  description = "Egress protocol."
  type        = string
}

variable "egress_cidr_blocks" {
  description = "Egress CIDR blocks."
  type        = list(string)
}
