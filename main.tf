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

data "aws_ami" "selected" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.os_name}*"]
  }

  filter {
    name   = "virtualization-type"
    values = [var.virtualization_type]
  }

  owners = [var.ami_owner]
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/${var.key_name}.pem"
  file_permission = "0600"
}

resource "aws_instance" "web" {
  count           = var.instance_count
  ami             = data.aws_ami.selected.id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.key_pair.key_name
  security_groups = [aws_security_group.web_sg.name]
  placement_group = aws_placement_group.placement_group.name

  tags = {
    Name = "${var.instance_name}-${count.index + 1}"
  }
}

resource "aws_placement_group" "placement_group" {
  name     = "${var.instance_name}-placement-group"
  strategy = "cluster"
}



resource "aws_security_group" "web_sg" {
  name        = var.sg_name
  description = var.sg_description

  ingress {
    from_port   = var.start_port
    to_port     = var.end_port
    protocol    = var.protocol
    cidr_blocks = var.cidr_blocks
  }
}


