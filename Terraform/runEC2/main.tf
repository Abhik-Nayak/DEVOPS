# Step 1: Configure AWS provider -- tells Terraform to use AWS in Mumbai (ap-south-1)
provider "aws" {
  region = "ap-south-1"
}

# Step 2: Create a custom VPC -- your own isolated network (replaces the default VPC)
# 10.0.0.0/16 gives you 65,536 private IPs (10.0.0.0 - 10.0.255.255)
# enable_dns_support + enable_dns_hostnames let instances resolve DNS names (needed for SSM)
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "abhik-demo-vpc"
  }
}

# Step 3: Create a public subnet inside the VPC -- a subdivision where EC2 will live
# 10.0.1.0/24 gives 256 IPs (10.0.1.0 - 10.0.1.255) within the VPC's range
# map_public_ip_on_launch = true auto-assigns a public IP to any EC2 launched here
# (default VPC did this automatically; custom VPC does NOT, so we must enable it)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "abhik-demo-public-subnet"
  }
}

# Step 4: Internet Gateway -- the door between your VPC and the public internet
# Without this, nothing inside your VPC can reach the internet (or be reached from it)
# Default VPC comes with one; custom VPC does NOT, so we must create it
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "abhik-demo-igw"
  }
}

# Step 5: Route Table -- tells traffic WHERE to go
# The route 0.0.0.0/0 -> internet gateway means "send all internet-bound traffic through the IGW"
# Without this route, your EC2 has no path to the internet even with an IGW attached
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "abhik-demo-public-rt"
  }
}

# Step 6: Associate the route table with our subnet -- links the routing rules to the subnet
# A subnet without an explicit route table association uses the VPC's "main" route table (which has no internet route)
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Step 7: Security Group -- virtual firewall; now explicitly placed inside our custom VPC
resource "aws_security_group" "web_sg" {
  name        = "ec2-web-sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.main.id

  # Allow inbound HTTP (port 80) from anywhere
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic -- needed for package downloads, DNS, AWS API calls
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Step 8: IAM Role -- lets EC2 talk to SSM (so you can connect without SSH keys or port 22)
resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2-ssm-role"

  # Trust policy: only EC2 service can assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Step 9: Attach AWS-managed SSM policy to the role -- grants actual SSM permissions
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Step 10: Instance Profile -- required wrapper; EC2 can't use IAM roles directly
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

# Step 11: Create the EC2 instance -- this ties everything together
resource "aws_instance" "web_server" {
  ami           = "ami-0f58b397bc5c1f2e8" # Amazon Linux 2023 (ap-south-1), AMI IDs are region-specific
  instance_type = "t2.micro"              # 1 vCPU, 1 GB RAM, free-tier eligible

  subnet_id              = aws_subnet.public.id                          # Place in our custom subnet
  vpc_security_group_ids = [aws_security_group.web_sg.id]                # Attach our firewall rules
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name # Attach SSM access

  tags = {
    Name = "abhik-demo-ec2"
  }
}

# Step 12: Outputs -- printed after `terraform apply`, re-check anytime with `terraform output`
output "instance_public_ip" {
  value       = aws_instance.web_server.public_ip
  description = "Public IP of the EC2 instance"
}

output "instance_id" {
  value       = aws_instance.web_server.id
  description = "Instance ID -- use with: aws ssm start-session --target <id>"
}
