# =============================================================================
# LAB 3: Mini-Network - VPC + Subnet + Internet Gateway + EC2
# =============================================================================
#
# GOAL: Understand how resources depend on each other
#
# This lab builds a simplified version of your production-network.
# Compare this with: xyz-corporation-vpc/production-network/main.tf
#
# ARCHITECTURE:
#
#   Internet
#      |
#   [ Internet Gateway ]
#      |
#   [ VPC: 10.0.0.0/16 ]
#      |
#   [ Public Subnet: 10.0.1.0/24 ]
#      |
#   [ Route Table ] --> 0.0.0.0/0 --> IGW
#      |
#   [ EC2 Instance ]
#
# DEPENDENCY CHAIN (Terraform figures this out automatically):
#   VPC --> Internet Gateway
#   VPC --> Subnet
#   VPC --> Route Table
#   Subnet + Route Table --> Route Table Association
#   Subnet + Security Group --> EC2 Instance
#
# INSTRUCTIONS:
#   1. Read this file top to bottom - notice how each resource references others
#   2. Run: terraform init
#   3. Run: terraform plan  (count how many resources will be created)
#   4. Run: terraform apply
#   5. Run: terraform state list  (see all managed resources)
#   6. Run: terraform graph  (see the dependency graph)
#   7. Try to SSH or curl the public IP from the output
#   8. Run: terraform destroy
#
# ESTIMATED TIME: 15 minutes
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
  region = var.aws_region
}

# -----------------------------------------------------------------------------
# STEP 1: Create the VPC (the container for everything)
# This is always the first resource in any AWS network setup
# Think of it as your own private section of AWS's network
# -----------------------------------------------------------------------------
resource "aws_vpc" "day1_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "day1-vpc"
  }
}

# -----------------------------------------------------------------------------
# STEP 2: Create an Internet Gateway (the door to the internet)
# Without this, nothing in your VPC can reach the internet
# Notice: vpc_id references the VPC above - Terraform knows to create VPC first
# -----------------------------------------------------------------------------
resource "aws_internet_gateway" "day1_igw" {
  vpc_id = aws_vpc.day1_vpc.id # <-- DEPENDENCY: needs VPC to exist first

  tags = {
    Name = "day1-igw"
  }
}

# -----------------------------------------------------------------------------
# STEP 3: Create a public subnet
# A subnet is a range of IPs within your VPC
# "map_public_ip_on_launch = true" means EC2s here get public IPs automatically
# -----------------------------------------------------------------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.day1_vpc.id # <-- DEPENDENCY: needs VPC
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "day1-public-subnet"
  }
}

# -----------------------------------------------------------------------------
# STEP 4: Create a route table (traffic rules)
# This says: "any traffic going to 0.0.0.0/0 (anywhere) should go through the IGW"
# Without this, your subnet has no route to the internet even though IGW exists
# -----------------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.day1_vpc.id # <-- DEPENDENCY: needs VPC

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.day1_igw.id # <-- DEPENDENCY: needs IGW
  }

  tags = {
    Name = "day1-public-rt"
  }
}

# -----------------------------------------------------------------------------
# STEP 5: Associate the route table with the subnet
# This connects the "traffic rules" to the actual subnet
# Without this, the subnet uses the VPC's default route table (no internet)
# -----------------------------------------------------------------------------
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id      # <-- DEPENDENCY: needs subnet
  route_table_id = aws_route_table.public.id  # <-- DEPENDENCY: needs route table
}

# -----------------------------------------------------------------------------
# STEP 6: Create a security group (firewall rules)
# Controls what traffic can reach your EC2 instance
# This allows: SSH (port 22), HTTP (port 80) inbound, and all outbound
# -----------------------------------------------------------------------------
resource "aws_security_group" "web" {
  name        = "day1-web-sg"
  description = "Allow SSH and HTTP inbound"
  vpc_id      = aws_vpc.day1_vpc.id # <-- DEPENDENCY: needs VPC

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
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
    Name = "day1-web-sg"
  }
}

# -----------------------------------------------------------------------------
# STEP 7: Launch the EC2 instance
# This is the actual server - notice how it references subnet and security group
# Terraform will create VPC -> Subnet -> SG -> EC2 in the correct order
# -----------------------------------------------------------------------------
resource "aws_instance" "web" {
  ami                    = "ami-0f58b397bc5c1f2e8"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id              # <-- DEPENDENCY
  vpc_security_group_ids = [aws_security_group.web.id]       # <-- DEPENDENCY

  tags = {
    Name = "day1-web-server"
  }
}
