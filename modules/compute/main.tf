data "aws_subnet" "selected" {
  id = var.subnet_id
}

resource "aws_instance" "web" {
  count = var.instance_count

  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  private_ip = (
    var.private_ip_start == null
    ? null
    : cidrhost(data.aws_subnet.selected.cidr_block, var.private_ip_start + count.index)
  )
  vpc_security_group_ids      = var.security_group_ids
  user_data                   = var.user_data
  user_data_replace_on_change = var.user_data_replace_on_change

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${count.index + 1}"
  })

  lifecycle {
    precondition {
      condition = (
        var.private_ip_start == null ||
        try(
          cidrhost(
            data.aws_subnet.selected.cidr_block,
            var.private_ip_start + count.index
          ) != cidrhost(data.aws_subnet.selected.cidr_block, -1),
          false
        )
      )
      error_message = "The calculated private IP must fit in the subnet and avoid its reserved final address."
    }
  }
}

resource "aws_ebs_volume" "main" {
  count = var.data_volume.enabled ? var.instance_count : 0

  availability_zone = data.aws_subnet.selected.availability_zone
  size              = var.data_volume.size
  type              = var.data_volume.type
  encrypted         = var.data_volume.encrypted

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-data-${count.index + 1}"
  })
}

resource "aws_volume_attachment" "main" {
  count = var.data_volume.enabled ? var.instance_count : 0

  device_name = var.data_volume.device_name
  volume_id   = aws_ebs_volume.main[count.index].id
  instance_id = aws_instance.web[count.index].id
}
