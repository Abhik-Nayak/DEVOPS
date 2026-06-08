# =============================================
# Day 01 — Terraform State + First EC2
# =============================================
# Deliverable: EC2 instance + S3 remote backend + DynamoDB state locking
# You only need this one file: main.tf


# ===========================================
# PART 1 — LOCAL STATE (do this first)
# ===========================================

# STEP 1: Terraform block
# - Write a "terraform" block with a "required_providers" block inside
# - Inside required_providers, define "aws" with:
#     source  = "hashicorp/aws"
#     version = "~> 5.0"
# - Also set required_version = ">= 1.0"
# YOUR CODE BELOW:



# STEP 2: AWS Provider
# - Write a "provider" block for "aws"
# - Set region = "ap-south-1" (or your preferred region)
# YOUR CODE BELOW:



# STEP 3: Security Group
# - Write: resource "aws_security_group" "web_sg" { ... }
# - Set name and description
# - Add an "ingress" block for SSH:
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]    (open for now; lock to your IP later)
# - Add an "ingress" block for HTTP:
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
# - Add an "egress" block to allow ALL outbound:
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
# - Add a tags block with Name
# YOUR CODE BELOW:



# STEP 4: EC2 Instance
# - Write: resource "aws_instance" "my_server" { ... }
# - Set ami = "<your-region-ami-id>"
#   (Go to AWS Console > EC2 > Launch Instance > copy Amazon Linux 2 AMI ID)
# - Set instance_type = "t3.micro"
# - Attach the security group:
#     vpc_security_group_ids = [aws_security_group.web_sg.id]
# - Add a tags block:
#     Name = "Day01-Server"
# YOUR CODE BELOW:



# ===========================================
# NOW RUN THESE COMMANDS:
#   terraform init
#   terraform plan
#   terraform apply
# Then go to AWS Console > EC2 and verify your instance is running.
# Open the terraform.tfstate file that was created — read the JSON.
# ===========================================


# ===========================================
# PART 2 — REMOTE STATE (do this after Part 1 works)
# ===========================================

# BEFORE STEP 5: Manually create these in AWS Console (or CLI):
#   1. S3 Bucket:
#      - Name: "<your-name>-terraform-state" (must be globally unique)
#      - Enable versioning on the bucket
#   2. DynamoDB Table:
#      - Table name: "terraform-locks"
#      - Partition key: "LockID" (type: String)  <-- must be exactly "LockID"

# STEP 5: Add backend config inside your terraform block from Step 1
# - Go back to your "terraform { ... }" block at the top
# - Add a "backend" block inside it:
#     backend "s3" {
#       bucket         = "<your-bucket-name>"
#       key            = "day-01/terraform.tfstate"
#       region         = "ap-south-1"
#       dynamodb_table = "terraform-locks"
#       encrypt        = true
#     }

# ===========================================
# NOW RUN:
#   terraform init
#   (Terraform will ask: "Do you want to migrate state to S3?" → type "yes")
#   Verify: your local terraform.tfstate should now be nearly empty.
#   Your real state lives in the S3 bucket now.
# ===========================================


# ===========================================
# PART 3 — LIFECYCLE COMMANDS (practice these)
# ===========================================

# STEP 6: Make a change
# - Go to your aws_instance resource above
# - Add or modify a tag, e.g.: Environment = "dev"
# - Run: terraform plan    → read the diff (+, -, ~ symbols)
# - Run: terraform apply   → confirm the change

# STEP 7: Destroy everything
# - Run: terraform destroy
# - Type "yes" to confirm
# - KEEP the S3 bucket and DynamoDB table — you'll reuse them in future days
