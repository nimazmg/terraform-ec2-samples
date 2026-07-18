# Structural moves for environments created with the pre-module-refactor layout.
# The primary/secondary keys match the supplied terraform.tfvars configuration.
moved {
  from = module.network.aws_subnet.main
  to   = module.network.aws_subnet.public["primary"]
}

moved {
  from = module.network.aws_subnet.secondary
  to   = module.network.aws_subnet.public["secondary"]
}

moved {
  from = module.network.aws_route_table_association.public
  to   = module.network.aws_route_table_association.public["primary"]
}

moved {
  from = module.network.aws_route_table_association.public_secondary
  to   = module.network.aws_route_table_association.public["secondary"]
}

moved {
  from = module.network.aws_alb.main
  to   = module.load_balancer.aws_alb.main
}

moved {
  from = module.network.aws_lb_target_group.main
  to   = module.load_balancer.aws_lb_target_group.main
}

moved {
  from = aws_lb_listener.http
  to   = module.load_balancer.aws_lb_listener.http
}

moved {
  from = aws_lb_target_group_attachment.compute
  to   = module.load_balancer.aws_lb_target_group_attachment.compute
}

moved {
  from = module.security_group.aws_security_group.main
  to   = module.alb_security_group.aws_security_group.main
}

moved {
  from = module.compute.aws_security_group.efs
  to   = module.efs.aws_security_group.efs
}

moved {
  from = module.compute.aws_efs_file_system.main
  to   = module.efs.aws_efs_file_system.main
}

moved {
  from = module.compute.aws_efs_mount_target.main
  to   = module.efs.aws_efs_mount_target.main["primary"]
}

moved {
  from = module.compute.tls_private_key.ssh
  to   = module.ssh_key.tls_private_key.ssh[0]
}

moved {
  from = module.compute.aws_key_pair.main
  to   = module.ssh_key.aws_key_pair.main[0]
}

moved {
  from = module.compute.local_file.private_key
  to   = module.ssh_key.local_file.private_key[0]
}
