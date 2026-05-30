output "vpc_id" {
  description = "Production VPC ID"
  value       = aws_vpc.production.id
}

output "web_subnet_id" {
  value = aws_subnet.web.id
}

output "app1_subnet_id" {
  value = aws_subnet.app1.id
}

output "app2_subnet_id" {
  value = aws_subnet.app2.id
}

output "dbcache_subnet_id" {
  value = aws_subnet.dbcache.id
}

output "db_subnet_id" {
  value = aws_subnet.db.id
}

output "web_instance_public_ip" {
  description = "Public IP of the web instance"
  value       = aws_instance.web.public_ip
}

output "nat_gateway_public_ip" {
  description = "NAT Gateway public IP (used by app1 and dbcache for outbound)"
  value       = aws_eip.nat_eip.public_ip
}

output "db_route_table_id" {
  description = "Route table ID for the DB/isolated subnets (needed for VPC peering routes)"
  value       = aws_route_table.private_isolated.id
}
