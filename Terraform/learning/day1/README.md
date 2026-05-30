# Day 1 - Terraform Fundamentals

## What is Terraform?

You write `.tf` files describing what infrastructure you want. Terraform creates it.
You change the file, Terraform updates the infrastructure. You delete the file, Terraform destroys it.

That's it. Everything else is details.

---

## The Only 4 Commands You Need

```powershell
terraform init      # Download provider plugins (run once per project)
terraform plan      # Preview what will happen (READ THIS EVERY TIME)
terraform apply     # Actually create/update/delete resources
terraform destroy   # Delete everything this config manages
```

---

## HCL Syntax - The 3 Blocks That Matter

```hcl
# 1. PROVIDER - which cloud, which region
provider "aws" {
  region = "ap-south-1"
}

# 2. RESOURCE - what to create
resource "aws_instance" "my_server" {
  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = "t2.micro"
  tags = { Name = "my-server" }
}

# 3. VARIABLE - make values reusable
variable "region" {
  type    = string
  default = "ap-south-1"
}
```

**How resources reference each other:**
```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "web" {
  vpc_id     = aws_vpc.main.id        # <-- Terraform creates VPC first automatically
  cidr_block = "10.0.1.0/24"
}
```

Pattern: `resource_type.local_name.attribute`

---

## Reading `terraform plan` Output

```
+   = will CREATE
-   = will DESTROY
~   = will UPDATE in-place
-/+ = will DESTROY and RECREATE
```

**If you learn one habit today:** Read every line of `terraform plan` before typing `yes`.

---

## State File Rules

After `apply`, Terraform creates `terraform.tfstate`. Three rules:
1. Never edit it manually
2. Never delete it
3. Never commit it to git (add to `.gitignore`)

---

## Hands-On Labs

Do these in order. Each builds on the previous one.

| Lab | What You'll Learn | Time |
|-----|------------------|------|
| `lab1-hello-terraform/` | The full workflow: init → plan → apply → destroy | 10 min |
| `lab2-variables-outputs/` | Parameterize config, display values after apply | 10 min |
| `lab3-mini-network/` | How resources depend on each other (VPC → Subnet → EC2) | 15 min |
| `lab4-modify-experiment/` | What happens when you change existing infrastructure | 15 min |

**For each lab:**
```powershell
cd <lab-folder>
terraform init
terraform plan       # READ THIS
terraform apply      # type 'yes'
# ... experiment ...
terraform destroy    # ALWAYS clean up
```

---

## Quick Reference

```
var.name                          # Use a variable
aws_vpc.main.id                   # Reference another resource
"${var.region}a"                  # String interpolation
terraform fmt                     # Auto-format your code
registry.terraform.io             # Look up any resource's arguments
```

---

## Day 1 Checklist

- [ ] Can you run `terraform init` → `plan` → `apply` → `destroy` without notes?
- [ ] Can you read a plan and know what `+`, `~`, `-` mean?
- [ ] Can you write a `main.tf` from memory that creates one EC2?
- [ ] Do you understand why `aws_subnet` needs `aws_vpc.xxx.id`?

If yes to all 4, you're ready for Day 2.
