# Step 1: Tell Terraform we want to use AWS
provider "aws" {
  region = "ap-south-1"  # The AWS region where the bucket will be created
}

# Step 2: Create an S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "abhik-demo-bucket-2026"  # Change this to a globally unique name
}
