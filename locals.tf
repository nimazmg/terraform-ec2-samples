locals {
  ssh_key_name = coalesce(var.compute.ssh_key_name, "${var.project_name}-key")
  ami_id       = var.compute.ami_id != null ? var.compute.ami_id : data.aws_ami.selected[0].id

  user_data = templatefile("${path.module}/templates/user_data.sh", {
    application_port  = var.application.target_port
    efs_dns_name      = module.efs.dns_name
    health_check_path = var.application.health_check.path
    project_name      = var.project_name
  })
}
