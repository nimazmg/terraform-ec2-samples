# EC2 variables
variable "instance_type" {}
variable "instance_name" {}
variable "key_name" {}
variable "instance_count" {
  type    = number
  default = 1
}
# data section
variable "os_name" {}
variable "ami_owner" {}
variable "virtualization_type" { default = "hvm" }
# security group variables
variable "sg_name" {}
variable "sg_description" {}
variable "start_port" {}
variable "end_port" {}
variable "cidr_blocks" {}
variable "protocol" {}

variable "aws_region" {
  description = "AWS region for the provider"
}
