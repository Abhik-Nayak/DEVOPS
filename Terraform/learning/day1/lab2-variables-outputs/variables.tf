# =============================================================================
# LAB 2: Variables - Input Parameters for Your Config
# =============================================================================
#
# Variables make your Terraform code reusable.
# Instead of hardcoding values, you define them here and reference with var.xxx
#
# You can set variable values in 4 ways (in order of precedence):
#   1. Command line:   terraform apply -var="instance_type=t2.small"
#   2. tfvars file:    terraform apply -var-file="prod.tfvars"
#   3. Environment:    $env:TF_VAR_instance_type = "t2.small"
#   4. Default value:  defined below
# =============================================================================

variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "day1-with-variables"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "learning"
}
