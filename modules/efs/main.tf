resource "aws_security_group" "efs" {
  name        = "${var.name_prefix}-efs-sg"
  description = "Allow NFS traffic from application instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NFS from application security groups"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
  }

  egress {
    description = "Allow all outbound IPv4 traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-efs-sg"
  })
}

resource "aws_efs_file_system" "main" {
  creation_token   = "${var.name_prefix}-efs"
  encrypted        = var.encrypted
  performance_mode = var.performance_mode
  throughput_mode  = var.throughput_mode

  dynamic "lifecycle_policy" {
    for_each = var.transition_to_ia == null ? [] : [var.transition_to_ia]

    content {
      transition_to_ia = lifecycle_policy.value
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-efs"
  })

  lifecycle {
    precondition {
      condition = !(
        var.performance_mode == "maxIO" &&
        var.throughput_mode == "elastic"
      )
      error_message = "EFS maxIO performance mode cannot be combined with elastic throughput."
    }
  }
}

resource "aws_efs_mount_target" "main" {
  for_each = var.subnet_ids

  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
}
