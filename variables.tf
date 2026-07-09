variable "aws_region" {
  description = "AWS region for the provider."
  type        = string
}

# EC2 variables
variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "instance_name" {
  description = "Name prefix for created resources."
  type        = string
}

variable "key_name" {
  description = "AWS key pair name."
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances and ENIs to create."
  type        = number
  default     = 1
}

variable "placement_strategy" {
  description = "EC2 placement group strategy."
  type        = string
}

variable "private_key_algorithm" {
  description = "Private key algorithm."
  type        = string
}

variable "private_key_rsa_bits" {
  description = "RSA key size."
  type        = number
}

variable "private_key_file_permission" {
  description = "Private key file permissions."
  type        = string
}

variable "primary_network_device_index" {
  description = "Device index for the primary ENI."
  type        = number
}

# AMI lookup variables
variable "os_name" {
  description = "AMI name prefix to search for."
  type        = string
}

variable "ami_owner" {
  description = "AWS account ID that owns the AMI."
  type        = string
}

variable "virtualization_type" {
  description = "AMI virtualization type."
  type        = string
}

# Network variables
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

variable "map_public_ip_on_launch" {
  description = "Whether instances launched in the subnet receive public IPs by default."
  type        = bool
}

variable "default_route_cidr_block" {
  description = "Destination CIDR block for the default route."
  type        = string
}

variable "private_ip_start" {
  description = "Host number for the first ENI private IP inside the subnet CIDR."
  type        = number
}

# Security group variables
variable "sg_name" {
  description = "Security group name."
  type        = string
}

variable "sg_description" {
  description = "Security group description."
  type        = string
}

variable "start_port" {
  description = "Ingress start port."
  type        = number
}

variable "end_port" {
  description = "Ingress end port."
  type        = number
}

variable "cidr_blocks" {
  description = "Ingress CIDR blocks."
  type        = list(string)
}

variable "protocol" {
  description = "Ingress protocol."
  type        = string
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
