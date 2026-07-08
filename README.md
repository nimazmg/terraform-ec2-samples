# terraform-ec2-samples

A simple Terraform project to provision an AWS EC2 instance and security group.

## Files

- `main.tf` - AWS provider and EC2 instance/security group resources
- `variables.tf` - input variable definitions
- `terraform.tfvars` - sample values for deployment

## Notes

- The AWS region is configured via `aws_region`.
- Do not commit any sensitive values or state files.
