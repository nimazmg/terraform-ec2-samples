terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"

  name_prefix              = var.instance_name
  vpc_cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames     = var.enable_dns_hostnames
  enable_dns_support       = var.enable_dns_support
  subnet_cidr_block        = var.subnet_cidr_block
  map_public_ip_on_launch  = var.map_public_ip_on_launch
  default_route_cidr_block = var.default_route_cidr_block
}

module "security_group" {
  source = "./modules/security_group"

  name                = var.sg_name
  description         = var.sg_description
  vpc_id              = module.network.vpc_id
  ingress_from_port   = var.start_port
  ingress_to_port     = var.end_port
  ingress_protocol    = var.protocol
  ingress_cidr_blocks = var.cidr_blocks
  egress_from_port    = var.egress_from_port
  egress_to_port      = var.egress_to_port
  egress_protocol     = var.egress_protocol
  egress_cidr_blocks  = var.egress_cidr_blocks
}

module "compute" {
  source = "./modules/compute"

  os_name             = var.os_name
  ami_owner           = var.ami_owner
  virtualization_type = var.virtualization_type
  key_name            = var.key_name
  instance_count      = var.instance_count
  instance_type       = var.instance_type
  instance_name       = var.instance_name
  placement_strategy  = var.placement_strategy
  subnet_id           = module.network.subnet_id
  subnet_cidr_block   = var.subnet_cidr_block
  private_ip_start    = var.private_ip_start
  security_group_ids  = [module.security_group.security_group_id]

  private_key_algorithm       = var.private_key_algorithm
  private_key_rsa_bits        = var.private_key_rsa_bits
  private_key_file_permission = var.private_key_file_permission
}
