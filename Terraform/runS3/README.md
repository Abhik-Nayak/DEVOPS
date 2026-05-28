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

## File Structure

| File | What it does |
|---|---|
| `main.tf` | The main config file — defines the AWS provider and the S3 bucket resource. This is the only file you edit. |
| `.gitignore` | Tells Git which files to ignore (state files, secrets, plugin folders). |
| `.terraform/` | Auto-created by `terraform init`. Contains the downloaded AWS provider plugin. Never edit this. |
| `.terraform.lock.hcl` | Auto-created by `terraform init`. Locks the exact provider version. Like `package-lock.json` in Node.js. |
| `terraform.tfstate` | Auto-created by `terraform apply`. Stores the current state of your resources. Terraform uses this to know what exists in AWS. **Do not delete or edit manually.** |
| `terraform.tfstate.backup` | Auto-created backup of the previous state file. Safety net if state gets corrupted. |

## Terraform Command Flow

```
terraform init  ──→  Downloads plugins into .terraform/
                     Creates .terraform.lock.hcl
                         │
terraform plan  ──→  Reads main.tf + terraform.tfstate
                     Shows what will be created/changed/destroyed
                     (nothing actually happens)
                         │
terraform apply ──→  Creates resources in AWS
                     Saves the result in terraform.tfstate
                         │
terraform destroy ─→  Deletes all resources from AWS
                      Updates terraform.tfstate
```

## Common Failures

| Reason | Description |
|---|---|
| Bucket name already taken | S3 names are globally unique across all AWS accounts |
| Invalid bucket name | No uppercase, no underscores, 3–63 chars, must start/end with letter or number |
| No AWS credentials | Missing or expired access keys — run `aws configure` |
| No permission | IAM user lacks `s3:CreateBucket` — needs `AmazonS3FullAccess` policy |
| Account bucket limit | Default limit is 100 buckets per account |
| Invalid region | Wrong region name or region disabled in account settings |
| Network issues | No internet, firewall blocking AWS APIs, or VPN problems |
