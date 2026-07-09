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

variable "availability_zone" {
  description = "Availability zone for the EC2 instance and EBS volume."
  type        = string
}

variable "ebs_volume_size" {
  description = "Size of the EBS volume in GiB."
  type        = number
}

variable "ebs_volume_type" {
  description = "Type of the EBS volume."
  type        = string
}

variable "key_name" {
  description = "AWS key pair name."
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances and ENIs to create."
  type        = number
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "instance_name" {
  description = "Name prefix for compute resources."
  type        = string
}

variable "placement_strategy" {
  description = "EC2 placement group strategy."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for ENIs."
  type        = string
}

variable "subnet_cidr_block" {
  description = "CIDR block for calculating ENI private IPs."
  type        = string
}

variable "private_ip_start" {
  description = "Host number for the first ENI private IP inside the subnet CIDR."
  type        = number
}

variable "security_group_ids" {
  description = "Security group IDs to attach to ENIs."
  type        = list(string)
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
