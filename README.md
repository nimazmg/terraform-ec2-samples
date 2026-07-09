# Terraform EC2 AWS Project

This is a learning Terraform project that provisions a small AWS EC2 environment using local Terraform modules.

The root module is kept mostly as wiring. The actual resources are split into separate modules for networking, security groups, and compute.

## What This Creates

- A VPC
- An internet gateway
- A subnet in a selected Availability Zone
- A route table and route table association
- A security group with configurable ingress and egress rules
- An EC2 instance
- An SSH key pair
- A local private key file
- An EBS volume
- An EBS volume attachment from the volume to the EC2 instance

## Project Structure

```text
.
|-- main.tf
|-- variables.tf
|-- terraform.tfvars
|-- README.md
|-- terraform-learning-notes-2026-07-09.md
`-- modules
    |-- compute
    |   |-- main.tf
    |   |-- outputs.tf
    |   `-- variables.tf
    |-- network
    |   |-- main.tf
    |   |-- outputs.tf
    |   `-- variables.tf
    `-- security_group
        |-- main.tf
        |-- outputs.tf
        `-- variables.tf
```

## Modules

### Network Module

The `modules/network` module creates:

- VPC
- Internet gateway
- Subnet
- Route table
- Route table association

The subnet is pinned to the configured Availability Zone so the EC2 instance and EBS volume can be created in the same zone.

### Security Group Module

The `modules/security_group` module creates one security group with configurable:

- Ingress rules for inbound traffic
- Egress rules for outbound traffic

### Compute Module

The `modules/compute` module creates:

- Ubuntu AMI lookup
- TLS private key
- AWS key pair
- Local `.pem` private key file
- EC2 instance
- EBS volume
- EBS volume attachment

The EBS volume is attached to the matching EC2 instance using `count.index`.

## Important Variables

Edit values in `terraform.tfvars` before applying.

Example:

```hcl
aws_region        = "eu-central-1"
availability_zone = "eu-central-1a"

instance_type  = "t4g.micro"
instance_name  = "web-server"
instance_count = 1

ebs_volume_size = 8
ebs_volume_type = "gp3"
```

Important: `aws_region` and `availability_zone` are different.

```text
Region:            eu-central-1
Availability Zone: eu-central-1a
```

EBS volumes can only attach to EC2 instances in the same Availability Zone.

## Usage

Initialize Terraform:

```powershell
terraform init
```

Format the configuration:

```powershell
terraform fmt -recursive
```

Validate the configuration:

```powershell
terraform validate
```

Preview the changes:

```powershell
terraform plan
```

Apply the infrastructure:

```powershell
terraform apply
```

Destroy the infrastructure when finished:

```powershell
terraform destroy
```

## Notes for Learning

Terraform modules do not automatically share variables. If a child module uses `var.example`, that child module must declare `variable "example"` in its own `variables.tf`, and the root module must pass the value into the module block.

Example:

```hcl
module "compute" {
  source = "./modules/compute"

  availability_zone = var.availability_zone
}
```

Cluster placement groups are not needed for this simple EC2 project. Small instance types such as `t4g.micro` do not support every placement group strategy.

If you change from `t4g.micro` to `t2.micro`, remember that they use different CPU architectures:

```text
t4g.micro = ARM
t2.micro  = x86_64
```

Make sure the selected AMI matches the instance architecture.

## Safety Notes

Do not commit sensitive files to GitHub, especially:

- Terraform state files: `terraform.tfstate`
- Terraform state backups: `terraform.tfstate.backup`
- Private key files: `*.pem`
- Local Terraform cache: `.terraform/`
- Real secrets or credentials

This project creates a local private key file using the configured `key_name`. Keep that file private.

## Helpful Commands

Check what Terraform will create or change:

```powershell
terraform plan
```

Check all resources managed by Terraform:

```powershell
terraform state list
```

Show details for one resource:

```powershell
terraform state show <resource_address>
```

Reformat all Terraform files:

```powershell
terraform fmt -recursive
```

## Extra Notes

See [terraform-learning-notes-2026-07-09.md](terraform-learning-notes-2026-07-09.md) for the mistakes and lessons from building this project.
