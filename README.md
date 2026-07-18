# Modular EC2 Web Stack on AWS

This Terraform root module creates a small web stack and composes focused,
reusable child modules. The root configuration contains only environment
choices; each child module owns one infrastructure concern.

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

## Configure

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

## Use

```powershell
terraform init
terraform fmt -recursive
terraform validate
terraform test
terraform plan
terraform apply
```

`terraform test` uses mock providers, so it verifies the full module
composition without creating resources or requiring AWS credentials.

After apply, Terraform prints `application_url`, instance addresses, subnet
IDs, and EFS details:

```powershell
terraform output application_url
```

Destroy the training environment when it is no longer needed:

```powershell
terraform destroy
```

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
