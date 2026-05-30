# =============================================================================
# LAB 1: Hello Terraform - Your Very First Infrastructure
# =============================================================================
#
# GOAL: Create a single EC2 instance and understand the full workflow
#
# INSTRUCTIONS:
#   1. Read every line of this file first
#   2. Run: terraform init
#   3. Run: terraform plan     (read the output carefully!)
#   4. Run: terraform apply    (type 'yes' when asked)
#   5. Check AWS Console > EC2 > Instances
#   6. Run: terraform destroy  (clean up!)
#
# ESTIMATED TIME: 10 minutes
# ESTIMATED COST: ~$0.01 (t2.micro, destroyed in minutes)
# =============================================================================

# STEP 1: Tell Terraform which provider to use and where to download it
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# STEP 2: Configure the AWS provider with the region
provider "aws" {
  region = "ap-south-1" # Mumbai region
}

# STEP 3: Define the resource you want to create
#
#   "aws_instance" = resource type (defined by AWS provider)
#   "hello"        = YOUR local name (you choose this - used to reference it)
#
resource "aws_instance" "hello" {
  ami           = "ami-0f58b397bc5c1f2e8" # Amazon Linux 2 in ap-south-1
  instance_type = "t2.micro"              # Free tier eligible

  tags = {
    Name        = "day1-hello-terraform"
    Environment = "learning"
    ManagedBy   = "terraform"
  }
}
