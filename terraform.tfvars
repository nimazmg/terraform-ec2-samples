aws_region   = "eu-central-1"
project_name = "web-server"

network = {
  vpc_cidr_block = "10.0.0.0/16"

  public_subnets = {
    primary = {
      cidr_block        = "10.0.0.0/24"
      availability_zone = "eu-central-1a"
    }
    secondary = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "eu-central-1b"
    }
  }
}

compute = {
  instance_type    = "t2.micro"
  instance_count   = 2
  subnet_key       = "primary"
  private_ip_start = 10

  # Set create_ssh_key = false to reuse an existing EC2 key pair.
  create_ssh_key = true
  ssh_key_name   = "my-key"

  data_volume = {
    size = 8
    type = "gp3"
  }
}

application = {
  listener_port = 80
  target_port   = 80

  # Replace this with trusted CIDRs when the application should not be public.
  allowed_cidr_blocks = ["0.0.0.0/0"]
}

tags = {
  Environment = "training"
}
