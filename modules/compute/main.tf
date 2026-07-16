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

resource "aws_instance" "web" {
  count         = var.instance_count
  ami           = data.aws_ami.selected.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.main.key_name
  # placement_group        = aws_placement_group.main.name
  subnet_id              = var.subnet_id
  private_ip             = cidrhost(var.subnet_cidr_block, var.private_ip_start + count.index)
  vpc_security_group_ids = var.security_group_ids
  user_data              = file("${path.module}/user_data.sh")
  tags = {
    Name = "${var.instance_name}-${count.index + 1}"
  }
}
resource "aws_ebs_volume" "main" {
  count             = var.instance_count
  availability_zone = var.availability_zone
  size              = var.ebs_volume_size
  type              = var.ebs_volume_type
  encrypted = true
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
