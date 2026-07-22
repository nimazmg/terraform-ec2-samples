# Modular EC2 Web Stack on AWS

This Terraform root module creates a small web stack and composes focused,
reusable child modules. The root configuration contains only environment
choices; each child module owns one infrastructure concern.

It is intended for learning and small demonstrations. The default configuration
deploys two EC2 web servers behind an Application Load Balancer, with shared EFS
storage and one encrypted EBS data volume per instance.

## Architecture

```text
network
  |
  +-- ALB security group --> load balancer
  |
  +-- application security group --> EC2 instances
          |
          +-- EFS security group --> EFS mount targets
```

The stack includes:

- One VPC, an internet gateway, and public subnets in at least two AZs
- Separate least-privilege security groups for the ALB, instances, and EFS
- An Application Load Balancer, target group, listener, and registrations
- One or more EC2 instances with optional encrypted EBS data volumes
- An encrypted EFS file system with one mount target per configured subnet
- An optional Terraform-generated EC2 SSH key

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) 1.9 or later
- An AWS account and credentials that can create the resources listed above
- AWS credentials configured through the AWS CLI, environment variables, or
  another method supported by the AWS provider

The configuration uses AWS provider 6.x, Local provider 2.x, and TLS provider
4.x. Exact provider selections are recorded in `.terraform.lock.hcl`.

## Project Structure

```text
.
|-- main.tf                 # Root module composition only
|-- variables.tf            # Grouped environment-level inputs
|-- outputs.tf              # Useful connection and resource details
|-- providers.tf
|-- versions.tf
|-- locals.tf
|-- moved.tf                # State-address migrations from the old layout
|-- terraform.tfvars
|-- .terraform.lock.hcl     # Reproducible provider selections
|-- templates/
|   `-- user_data.sh
|-- tests/
|   `-- stack.tftest.hcl    # Credential-free composition test
`-- modules/
    |-- compute/
    |-- efs/
    |-- load_balancer/
    |-- network/
    |-- security_group/
    `-- ssh_key/
```

## Quick Start

1. Clone the repository and enter its directory.
2. Review `terraform.tfvars`, especially the region and availability zones.
3. Initialize and validate the configuration:

   ```powershell
   terraform init
   terraform fmt -check -recursive
   terraform validate
   terraform test
   ```

4. Review and apply the proposed infrastructure:

   ```powershell
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

5. Open the URL returned by Terraform:

   ```powershell
   terraform output -raw application_url
   ```

`terraform test` uses mock providers, so it verifies module composition without
creating resources or requiring AWS credentials. `plan` and `apply` use the real
AWS provider and therefore require valid credentials.

## Configuration

Most settings have safe defaults. The only topology-specific input is the
subnet map in `terraform.tfvars`:

```hcl
network = {
  vpc_cidr_block = "10.0.0.0/16"

  public_subnets = {
    primary = {
      cidr_block        = "10.0.0.0/24"
      availability_zone = "eu-central-1a"
    }
    secondary = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "eu-central-1b"
    }
  }
}
```

Subnets default to assigning public IPs because this training stack does not
create a NAT gateway. Inbound traffic to instances is still restricted to the
ALB security group. To enable SSH, explicitly set trusted source CIDRs:

```hcl
compute = {
  ssh_allowed_cidr_blocks = ["203.0.113.10/32"]
}
```

Never open SSH to `0.0.0.0/0`.

The default AMI search selects Ubuntu 22.04 on x86_64. When changing to an ARM
instance type such as `t4g.micro`, also change `compute.ami.architecture` and
the AMI name pattern. For stable environments, pin an image instead of using
the `most_recent` lookup:

```hcl
compute = {
  ami_id = "ami-0123456789abcdef0"
}
```

Key root inputs are:

| Input | Default | Purpose |
| --- | --- | --- |
| `aws_region` | `eu-central-1` | AWS region for the stack |
| `project_name` | `web-server` | Naming and tagging prefix |
| `network` | Required subnet map | VPC CIDR and public subnet topology |
| `compute` | `{}` | Instance, AMI, SSH key, and EBS settings |
| `application` | `{}` | Listener, target port, access CIDRs, and health check |
| `tags` | `{}` | Additional tags applied to supported AWS resources |

See `variables.tf` for the full object schemas, defaults, and validation rules.

## Outputs

After a successful apply, Terraform returns:

- `application_url` and `alb_dns_name`
- VPC, subnet, and security group identifiers
- EC2 instance IDs and private/public IP addresses
- EFS file system and mount-target details
- `private_key_path` when Terraform generates an SSH key

Destroy the training environment when it is no longer needed:

```powershell
terraform destroy
```

The stack creates billable AWS resources, including EC2 instances, EBS volumes,
an Application Load Balancer, and EFS storage. Running `terraform destroy` stops
future resource charges after AWS finishes deleting them.

## Reusing an Existing SSH Key

Terraform creates a key by default so the example is self-contained. To reuse
an existing EC2 key pair instead:

```hcl
compute = {
  create_ssh_key = false
  ssh_key_name   = "existing-key-name"
}
```

Generated private key material is stored in Terraform state and written to a
local `.pem` file. Protect the state as sensitive data; for production, prefer
an existing key or AWS Systems Manager Session Manager.

## Security Notes

- The load balancer is public by default because
  `application.allowed_cidr_blocks` defaults to `0.0.0.0/0`; restrict it when a
  public application is not required.
- SSH ingress is disabled by default and validation rejects `0.0.0.0/0` as an
  SSH source.
- EC2 instances receive public IPs in this training architecture so first-boot
  package installation works without a NAT gateway. For production, place
  instances in private subnets and use managed egress.
- Store Terraform state in a secure remote backend with encryption and access
  controls before using this configuration for shared environments.

## Module Boundaries

- `network` owns only VPC, subnet, gateway, route-table, and association
  resources.
- `security_group` is generic and can be instantiated for any role.
- `efs` owns the file system, NFS security group, and per-subnet mount targets.
- `compute` accepts an AMI ID and user data, and owns EC2/EBS resources only.
- `ssh_key` optionally creates and stores an EC2 key pair.
- `load_balancer` owns the ALB, target group, listener, and target attachments.

This produces a one-way dependency graph and lets each module be reused or
replaced independently.

## Existing-State Migration

`moved.tf` maps the old resource addresses to the new module addresses. Its
subnet migrations assume the supplied `primary` and `secondary` keys. If an
existing environment uses different keys, adjust those moves before planning.

Always review the first migration plan carefully. The refactor intentionally
adds a dedicated application security group, adds an EFS mount target in the
second AZ, enables instance public IPs so package installation works without a
NAT gateway, and removes the old unused duplicate EFS security group. Those
changes are expected even when all address moves are recognized.

The first migration can replace EC2 instances because public-IP assignment,
the AMI selection, and first-boot user data changed. Schedule downtime and
back up anything stored on instance root volumes before applying. Separate EBS
data volumes retain their stable resource addresses.

Do not commit state, `.pem` files, credentials, or secrets. The provider lock
file should be committed so provider selections remain repeatable.
