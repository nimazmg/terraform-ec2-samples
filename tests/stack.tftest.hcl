mock_provider "aws" {}
mock_provider "local" {}
mock_provider "tls" {}

run "plans_the_complete_stack" {
  command = plan

  assert {
    condition     = length(module.network.public_subnet_ids) >= 2
    error_message = "The stack must create at least two public subnets."
  }

  assert {
    condition     = length(module.compute.instance_ids) == var.compute.instance_count
    error_message = "The compute module must create the configured number of instances."
  }

  assert {
    condition     = length(module.efs.mount_target_ids) == length(var.network.public_subnets)
    error_message = "EFS must have one mount target per configured subnet."
  }
}

run "plans_with_existing_key_and_pinned_ami" {
  command = plan

  variables {
    compute = {
      ami_id         = "ami-0123456789abcdef0"
      create_ssh_key = false
      ssh_key_name   = "existing-key"
    }
  }

  assert {
    condition     = output.private_key_path == null
    error_message = "Reusing an existing key must not create a local private-key file."
  }
}
