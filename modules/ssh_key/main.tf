resource "tls_private_key" "ssh" {
  count = var.create ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = var.rsa_bits
}

resource "aws_key_pair" "main" {
  count = var.create ? 1 : 0

  key_name   = var.key_name
  public_key = tls_private_key.ssh[0].public_key_openssh

  tags = merge(var.tags, {
    Name = var.key_name
  })
}

resource "local_file" "private_key" {
  count = var.create ? 1 : 0

  content         = tls_private_key.ssh[0].private_key_pem
  filename        = var.private_key_filename
  file_permission = var.private_key_file_permission
}
