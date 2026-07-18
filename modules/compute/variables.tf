variable "name_prefix" {
  description = "Name prefix for compute resources."
  type        = string
}

variable "ami_id" {
  description = "AMI ID used for every instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t2.micro"
}

variable "instance_count" {
  description = "Number of EC2 instances to create."
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count >= 1 && var.instance_count == floor(var.instance_count)
    error_message = "instance_count must be a whole number of at least 1."
  }
}

variable "subnet_id" {
  description = "ID of the subnet in which to create the instances."
  type        = string
}

variable "associate_public_ip_address" {
  description = "Whether the instances receive public IPv4 addresses."
  type        = bool
  default     = false
}

variable "private_ip_start" {
  description = "Optional host offset for deterministic private IPs; null lets AWS assign them."
  type        = number
  default     = null

  validation {
    condition = (
      var.private_ip_start == null ||
      (
        var.private_ip_start >= 4 &&
        var.private_ip_start == floor(var.private_ip_start)
      )
    )
    error_message = "private_ip_start must be null or a whole-number host offset of at least 4."
  }
}

variable "security_group_ids" {
  description = "Security group IDs attached to every instance."
  type        = list(string)

  validation {
    condition     = length(var.security_group_ids) > 0
    error_message = "At least one security group ID is required."
  }
}

variable "key_name" {
  description = "Name of an existing or Terraform-created EC2 key pair."
  type        = string
}

variable "user_data" {
  description = "Optional cloud-init or shell user data."
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "Whether a user-data change should replace instances so first-boot configuration reruns."
  type        = bool
  default     = false
}

variable "data_volume" {
  description = "Optional EBS data volume attached to each instance."
  type = object({
    enabled     = optional(bool, true)
    size        = optional(number, 8)
    type        = optional(string, "gp3")
    encrypted   = optional(bool, true)
    device_name = optional(string, "/dev/sdf")
  })
  default = {}

  validation {
    condition = (
      var.data_volume.size >= 1 &&
      var.data_volume.size == floor(var.data_volume.size)
    )
    error_message = "data_volume.size must be a whole number of at least 1 GiB."
  }
}

variable "tags" {
  description = "Additional tags for supported resources."
  type        = map(string)
  default     = {}
}
