output "vpc_id" {
  description = "Development VPC ID"
  value       = aws_vpc.development.id
}

output "web_subnet_id" {
  value = aws_subnet.web.id
}

output "db_subnet_id" {
  value = aws_subnet.db.id
}

output "web_instance_public_ip" {
  description = "Public IP of the development web instance"
  value       = aws_instance.web.public_ip
}

output "peering_connection_id" {
  description = "VPC Peering Connection ID between production and development"
  value       = aws_vpc_peering_connection.prod_dev.id
}
