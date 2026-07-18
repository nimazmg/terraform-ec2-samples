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

  name_prefix                      = var.instance_name
  vpc_cidr_block                   = var.vpc_cidr_block
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  subnet_cidr_block                = var.subnet_cidr_block
  availability_zone                = var.availability_zone
  secondary_availability_zone      = var.secondary_availability_zone
  map_public_ip_on_launch          = var.map_public_ip_on_launch
  default_route_cidr_block         = var.default_route_cidr_block
  security_group_id                = module.security_group.security_group_id
  target_group_port                = var.target_group_port
  target_group_protocol            = var.target_group_protocol
  health_check_path                = var.health_check_path
  health_check_interval            = var.health_check_interval
  health_check_timeout             = var.health_check_timeout
  health_check_healthy_threshold   = var.health_check_healthy_threshold
  health_check_unhealthy_threshold = var.health_check_unhealthy_threshold
  health_check_matcher             = var.health_check_matcher
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
  name_sg_efs         = var.name_sg_efs
  description_sg_efs  = var.description_sg_efs
}

module "compute" {
  source = "./modules/compute"

  os_name                     = var.os_name
  ami_owner                   = var.ami_owner
  virtualization_type         = var.virtualization_type
  key_name                    = var.key_name
  instance_count              = var.instance_count
  instance_type               = var.instance_type
  instance_name               = var.instance_name
  placement_strategy          = var.placement_strategy
  subnet_id                   = module.network.subnet_id
  subnet_cidr_block           = var.subnet_cidr_block
  private_ip_start            = var.private_ip_start
  security_group_ids          = [module.security_group.security_group_id]
  availability_zone           = var.availability_zone
  ebs_volume_size             = var.ebs_volume_size
  ebs_volume_type             = var.ebs_volume_type
  private_key_algorithm       = var.private_key_algorithm
  private_key_rsa_bits        = var.private_key_rsa_bits
  private_key_file_permission = var.private_key_file_permission
  aws_region                  = var.aws_region
}

resource "aws_lb_target_group_attachment" "compute" {
  count            = length(module.compute.instance_ids)
  target_group_arn = module.network.target_group_arn
  target_id        = module.compute.instance_ids[count.index]
  port             = var.target_group_port
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = module.network.alb_arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = module.network.target_group_arn
  }
}