data "aws_ami" "selected" {
  count = var.compute.ami_id == null ? 1 : 0

  most_recent = true
  owners      = var.compute.ami.owners

  filter {
    name   = "name"
    values = [var.compute.ami.name_pattern]
  }

  filter {
    name   = "architecture"
    values = [var.compute.ami.architecture]
  }

  filter {
    name   = "virtualization-type"
    values = [var.compute.ami.virtualization_type]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

module "network" {
  source = "./modules/network"

  name_prefix              = var.project_name
  vpc_cidr_block           = var.network.vpc_cidr_block
  public_subnets           = var.network.public_subnets
  default_route_cidr_block = var.network.default_route_cidr_block
}

module "alb_security_group" {
  source = "./modules/security_group"

  name        = "${var.project_name}-alb-sg"
  description = "Allow public HTTP traffic to the application load balancer"
  vpc_id      = module.network.vpc_id

  ingress_rules = length(var.application.allowed_cidr_blocks) == 0 ? [] : [
    {
      description = "HTTP from allowed networks"
      from_port   = var.application.listener_port
      to_port     = var.application.listener_port
      protocol    = "tcp"
      cidr_blocks = var.application.allowed_cidr_blocks
    }
  ]
}

module "application_security_group" {
  source = "./modules/security_group"

  name        = "${var.project_name}-app-sg"
  description = "Allow application traffic from the load balancer"
  vpc_id      = module.network.vpc_id

  ingress_rules = concat(
    [
      {
        description        = "Application traffic from the load balancer"
        from_port          = var.application.target_port
        to_port            = var.application.target_port
        protocol           = "tcp"
        security_group_ids = [module.alb_security_group.id]
      }
    ],
    length(var.compute.ssh_allowed_cidr_blocks) == 0 ? [] : [
      {
        description = "SSH from explicitly allowed networks"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = var.compute.ssh_allowed_cidr_blocks
      }
    ]
  )
}

module "efs" {
  source = "./modules/efs"

  name_prefix                = var.project_name
  vpc_id                     = module.network.vpc_id
  subnet_ids                 = module.network.public_subnet_ids
  allowed_security_group_ids = [module.application_security_group.id]
}

module "ssh_key" {
  source = "./modules/ssh_key"

  create               = var.compute.create_ssh_key
  key_name             = local.ssh_key_name
  private_key_filename = "${path.root}/${local.ssh_key_name}.pem"
  rsa_bits             = var.compute.ssh_key_rsa_bits
}

module "compute" {
  source = "./modules/compute"

  name_prefix                 = var.project_name
  ami_id                      = local.ami_id
  instance_type               = var.compute.instance_type
  instance_count              = var.compute.instance_count
  subnet_id                   = module.network.public_subnet_ids[var.compute.subnet_key]
  associate_public_ip_address = var.network.public_subnets[var.compute.subnet_key].map_public_ip_on_launch
  private_ip_start            = var.compute.private_ip_start
  security_group_ids          = [module.application_security_group.id]
  key_name                    = module.ssh_key.key_name
  user_data                   = local.user_data
  user_data_replace_on_change = true
  data_volume                 = var.compute.data_volume

  depends_on = [module.efs]
}

module "load_balancer" {
  source = "./modules/load_balancer"

  name_prefix        = var.project_name
  vpc_id             = module.network.vpc_id
  subnet_ids         = values(module.network.public_subnet_ids)
  security_group_ids = [module.alb_security_group.id]
  listener_port      = var.application.listener_port
  target_port        = var.application.target_port
  target_ids         = module.compute.instance_ids
  health_check       = var.application.health_check
}
