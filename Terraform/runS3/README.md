# S3 Bucket — Terraform

Creates a single S3 bucket in AWS using Terraform.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- AWS CLI configured with credentials (`aws configure`)

## Usage

```bash
terraform init      # Download AWS provider plugin
terraform plan      # Preview what will be created
terraform apply     # Create the S3 bucket
terraform destroy   # Delete the bucket when done
```

## Configuration

Edit `main.tf` to change:

- **region** — AWS region (default: `ap-south-1`)
- **bucket** — S3 bucket name (must be globally unique)
