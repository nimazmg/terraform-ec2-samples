aws_region = "eu-central-1"

# EC2 variables
instance_type               = "t2.micro"
instance_name               = "web-server"
key_name                    = "my-key"
instance_count              = 2
placement_strategy          = "cluster"
private_key_algorithm       = "RSA"
private_key_rsa_bits        = 2048
private_key_file_permission = "0600"

# EBS variables
ebs_volume_size             = 8
ebs_volume_type             = "gp3"
availability_zone           = "eu-central-1a"
secondary_availability_zone = "eu-central-1b"

# AMI lookup variables
os_name             = "ubuntu"
ami_owner           = "099720109477"
virtualization_type = "hvm"

# Network variables
vpc_cidr_block           = "10.0.0.0/16"
enable_dns_hostnames     = true
enable_dns_support       = true
subnet_cidr_block        = "10.0.0.0/24"
map_public_ip_on_launch  = false
default_route_cidr_block = "0.0.0.0/0"
private_ip_start         = 10
#LB variables

target_group_port                = 80
target_group_protocol            = "HTTP"
health_check_path                = "/"
health_check_interval            = 30
health_check_timeout             = 5
health_check_healthy_threshold   = 2
health_check_unhealthy_threshold = 2
health_check_matcher             = "200-299"

# Security group variables
sg_name            = "web-sg"
sg_description     = "Allow HTTP traffic"
start_port         = 80
end_port           = 80
cidr_blocks        = ["0.0.0.0/0"]
protocol           = "tcp"
egress_from_port   = 0
egress_to_port     = 0
egress_protocol    = "-1"
egress_cidr_blocks = ["0.0.0.0/0"]

# EFS variables
name_sg_efs        = "efs-sg"
description_sg_efs = "Allow EFS traffic from EC2 instances"
