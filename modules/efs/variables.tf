variable "name_prefix" {
  description = "Name prefix for EFS resources."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC that contains the mount targets."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs keyed by stable names; one mount target is created per subnet."
  type        = map(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet ID is required."
  }
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to connect to EFS over NFS."
  type        = list(string)

  validation {
    condition     = length(var.allowed_security_group_ids) > 0
    error_message = "At least one source security group ID is required."
  }
}

variable "encrypted" {
  description = "Whether to encrypt the EFS file system at rest."
  type        = bool
  default     = true
}

variable "performance_mode" {
  description = "EFS performance mode."
  type        = string
  default     = "generalPurpose"

  validation {
    condition     = contains(["generalPurpose", "maxIO"], var.performance_mode)
    error_message = "performance_mode must be generalPurpose or maxIO."
  }
}

variable "throughput_mode" {
  description = "EFS throughput mode."
  type        = string
  default     = "bursting"

  validation {
    condition     = contains(["bursting", "elastic"], var.throughput_mode)
    error_message = "throughput_mode must be bursting or elastic."
  }
}

variable "transition_to_ia" {
  description = "Lifecycle transition to infrequent access; null disables the policy."
  type        = string
  default     = "AFTER_30_DAYS"
  nullable    = true
}

variable "tags" {
  description = "Additional tags for supported resources."
  type        = map(string)
  default     = {}
}
