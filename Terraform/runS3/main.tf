# Variable for AWS region — value comes from .tfvars file
variable "aws_region" {
  description = "AWS region to create resources in"
  type        = string
}

# Variable for bucket name — value comes from .tfvars file
variable "bucket_name" {
  description = "Name of the S3 bucket (must be globally unique)"
  type        = string
}

# Variable for environment tag
variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
}

# Create the S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
