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

data "aws_subnet" "selected" {
  id = var.subnet_id
}

resource "tls_private_key" "ssh" {
  algorithm = var.private_key_algorithm
  rsa_bits  = var.private_key_rsa_bits
}

resource "aws_key_pair" "main" {
  key_name   = var.key_name
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.root}/${var.key_name}.pem"
  file_permission = var.private_key_file_permission
}

# resource "aws_placement_group" "main" {
#   name     = "${var.instance_name}-placement-group"
#   strategy = var.placement_strategy
# }

resource "aws_security_group" "efs" {
  name        = "${var.instance_name}-efs-sg"
  description = "Allow NFS traffic from EC2 instances"
  vpc_id      = data.aws_subnet.selected.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = var.security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_efs_file_system" "main" {
  creation_token  = "${var.instance_name}-efs"
  encrypted       = true
  throughput_mode = "bursting"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "${var.instance_name}-efs"
  }
}

resource "aws_efs_mount_target" "main" {
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.subnet_id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_instance" "web" {
  count         = var.instance_count
  ami           = data.aws_ami.selected.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.main.key_name
  # placement_group        = aws_placement_group.main.name
  subnet_id              = var.subnet_id
  private_ip             = cidrhost(var.subnet_cidr_block, var.private_ip_start + count.index)
  vpc_security_group_ids = var.security_group_ids
  user_data = templatefile("${path.module}/user_data.sh", {
    efs_dns_name = aws_efs_file_system.main.dns_name
  })

  tags = {
    Name = "${var.instance_name}-${count.index + 1}"
  }
}

resource "aws_ebs_volume" "main" {
  count             = var.instance_count
  availability_zone = var.availability_zone
  size              = var.ebs_volume_size
  type              = var.ebs_volume_type
  encrypted         = true

  tags = {
    Name = "${var.instance_name}-ebs-volume-${count.index + 1}"
  }
}

resource "aws_volume_attachment" "main" {
  count       = var.instance_count
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.main[count.index].id
  instance_id = aws_instance.web[count.index].id
}