aws_region = "eu-central-1"

# EC2 variables
instance_type                = "t4g.micro"
instance_name                = "web-server"
key_name                     = "my-key"
instance_count               = 1
placement_strategy           = "cluster"
private_key_algorithm        = "RSA"
private_key_rsa_bits         = 2048
private_key_file_permission  = "0600"
primary_network_device_index = 0

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
