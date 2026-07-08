terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
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

resource "aws_instance" "web" {
  ami             = data.aws_ami.selected.id
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [aws_security_group.web_sg.name]
  tags = {
    Name = var.instance_name
  }
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
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = var.public_key
}


