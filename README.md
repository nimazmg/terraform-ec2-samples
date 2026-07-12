# Terraform EC2 AWS Project

This repository is a learning Terraform project that provisions a small AWS environment using local modules. The root module wires module inputs/outputs; resources live in `modules/`.

## What This Creates

- VPC and internet gateway
- Two public subnets (one per AZ) used by the Application Load Balancer
- Route table and associations
- Security group with configurable ingress/egress rules
- Application Load Balancer, target group, and listener
- EC2 instances (compute module)
- SSH keypair and local `.pem` file
- EBS volumes and attachments

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

The `modules/network` module creates the network resources used by the rest of the project. Key points:

- **VPC:** single VPC for the project.
- **Subnets:** two public subnets in different Availability Zones for ALB high-availability.
- **Internet gateway, route table, associations.**

The module exposes `vpc_id`, `subnet_id` (primary), and ALB outputs (`alb_arn`, `target_group_arn`).

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

This project currently attaches instances to a single subnet (module input). For HA across AZs, extend the compute module to deploy instances into multiple subnets.

## Important Variables

Edit values in `terraform.tfvars` before applying. Example values:

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

For the ALB, AWS requires at least two subnets in different Availability Zones. This project adds `secondary_availability_zone` and a second subnet; set it in `terraform.tfvars` (for example `eu-central-1b`).

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

If you prefer a safe preview-run, use `terraform plan` before `terraform apply`.

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

