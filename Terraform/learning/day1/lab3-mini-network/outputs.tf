# =============================================================================
# LAB 3: Outputs
# =============================================================================

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.day1_vpc.id
}

output "subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public.id
}

output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

output "resource_count" {
  description = "Total resources created in this lab"
  value       = "7 resources: VPC, IGW, Subnet, Route Table, RT Association, Security Group, EC2"
}
