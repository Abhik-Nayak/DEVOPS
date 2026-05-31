# =============================================================================
# LAB 2: Using Variables and Outputs
# =============================================================================
#
# GOAL: Parameterize your config so it's reusable
#
# INSTRUCTIONS:
#   1. Read variables.tf first (understand inputs)
#   2. Read this file (see how variables are used)
#   3. Read outputs.tf (see what gets displayed)
#   4. Run: terraform init
#   5. Run: terraform plan
#   6. Run: terraform plan -var="instance_name=my-custom-name"
#   7. Run: terraform apply
#   8. Run: terraform output
#   9. Run: terraform destroy
#
# ESTIMATED TIME: 10 minutes
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
  region = var.aws_region # <-- Using a variable instead of hardcoded value!
}

resource "aws_security_group" "server" {
  name        = "${var.instance_name}-sg"
  description = "Allow SSH inbound"

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.instance_name}-sg"
  }
}

resource "aws_instance" "server" {
  ami                    = "ami-0f58b397bc5c1f2e8"
  instance_type          = var.instance_type          # <-- Variable!
  key_name               = var.key_name               # <-- SSH key pair!
  vpc_security_group_ids = [aws_security_group.server.id]

  tags = {
    Name        = var.instance_name # <-- Variable!
    Environment = var.environment   # <-- Variable!
    ManagedBy   = "terraform"
  }
}
