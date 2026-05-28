# Step 1: Tell Terraform we want to use AWS
provider "aws" {
  region = "ap-south-1"
}

# Step 2: Create a Security Group (firewall rules)
resource "aws_security_group" "web_sg" {
  name        = "ec2-web-sg"
  description = "Allow SSH and HTTP traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
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
}

# Step 3: Create an EC2 instance
resource "aws_instance" "web_server" {
  ami           = "ami-0f58b397bc5c1f2e8" # Amazon Linux 2023 (ap-south-1)
  instance_type = "t2.micro"              # Free-tier eligible

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "abhik-demo-ec2"
  }
}

# Step 4: Output the public IP so we can connect
output "instance_public_ip" {
  value       = aws_instance.web_server.public_ip
  description = "Public IP of the EC2 instance"
}

output "instance_id" {
  value       = aws_instance.web_server.id
  description = "Instance ID"
}
