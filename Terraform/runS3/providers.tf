# Tells Terraform to use the AWS provider plugin
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Connects to AWS using the region passed as a variable
provider "aws" {
  region = var.aws_region
}
