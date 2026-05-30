# =============================================================================
# LAB 4: The Modification Experiment
# =============================================================================
#
# GOAL: Understand what happens when you CHANGE existing infrastructure
#
# This lab teaches you the 3 types of changes Terraform can make:
#   1. In-place update (~)  - modifies resource without recreating
#   2. Replace (-/+)        - destroys and recreates (some changes force this)
#   3. Delete (-)           - removes a resource
#
# INSTRUCTIONS:
#   1. Run: terraform init && terraform apply
#   2. Follow each EXPERIMENT below one at a time
#   3. After each change, run: terraform plan (READ THE OUTPUT!)
#   4. Then: terraform apply
#   5. After all experiments: terraform destroy
#
# =============================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "experiment" {
  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = "t2.micro"

  tags = {
    Name        = "day1-experiment"
    Environment = "learning"
  }
}

# =============================================================================
# EXPERIMENT 1: In-Place Update (change tags)
# =============================================================================
# After initial apply, change the Name tag above to "day1-experiment-modified"
# Then run: terraform plan
#
# EXPECTED: You'll see ~ (update in-place)
# WHY: Tags can be changed without recreating the instance
#
# OBSERVE: The plan shows which specific attributes changed
# =============================================================================

# =============================================================================
# EXPERIMENT 2: In-Place Update (change instance type)
# =============================================================================
# Change instance_type from "t2.micro" to "t2.small"
# Then run: terraform plan
#
# EXPECTED: You'll see ~ (update in-place) - Terraform will stop and resize
# WHY: Instance type can be changed by stopping the instance
#
# OBSERVE: The plan shows the old and new value side by side
# =============================================================================

# =============================================================================
# EXPERIMENT 3: Forced Replacement (change AMI)
# =============================================================================
# Change the ami to "ami-0dee22c13ea7a9a67" (Ubuntu instead of Amazon Linux)
# Then run: terraform plan
#
# EXPECTED: You'll see -/+ (destroy and recreate)
# WHY: You can't change the AMI of a running instance - must create a new one
#
# OBSERVE: The plan says "must be replaced" and shows the new instance will
#          get a different ID and IP address
# NOTE: Don't actually apply this one if you want to avoid cost - just read the plan
# =============================================================================

# =============================================================================
# EXPERIMENT 4: Adding a New Resource
# =============================================================================
# Uncomment the resource block below, then run: terraform plan
#
# EXPECTED: You'll see + (create) for just the new resource
# WHY: Terraform only changes what's different - existing instance is untouched
#
# OBSERVE: The existing instance shows NO changes
# =============================================================================

# Uncomment this block for Experiment 4:
#
# resource "aws_instance" "experiment2" {
#   ami           = "ami-0f58b397bc5c1f2e8"
#   instance_type = "t2.micro"
#
#   tags = {
#     Name = "day1-experiment-2"
#   }
# }

# =============================================================================
# EXPERIMENT 5: Deleting a Resource
# =============================================================================
# Comment out OR delete the entire "experiment" resource block at the top
# Then run: terraform plan
#
# EXPECTED: You'll see - (destroy)
# WHY: The resource is no longer in your config, so Terraform removes it
#
# OBSERVE: This is how Terraform handles "I don't want this anymore"
#          You don't run a "delete" command - you just remove it from config
# =============================================================================

# =============================================================================
# CLEAN UP
# =============================================================================
# After all experiments, make sure to run: terraform destroy
# This removes ALL resources managed by this configuration
# =============================================================================
