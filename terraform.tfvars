aws_region = "eu-central-1"
# EC2 variables
instance_type       = "t4g.micro"
instance_name       = "web-server"
virtualization_type = "hvm"
key_name            = "my-key"
instance_count      = 1
# data section
os_name   = "ubuntu"
ami_owner = "099720109477"
# security group variables
sg_name        = "web-sg"
sg_description = "Allow HTTP traffic"
start_port     = 80
end_port       = 80
cidr_blocks    = ["0.0.0.0/0"]
protocol       = "tcp"

