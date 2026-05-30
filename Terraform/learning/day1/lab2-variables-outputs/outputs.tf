# =============================================================================
# LAB 2: Outputs - Display Useful Information After Apply
# =============================================================================
#
# Outputs are printed after 'terraform apply' and can be queried with
# 'terraform output'. They're useful for:
#   - Displaying IP addresses to connect to
#   - Showing resource IDs for reference
#   - Passing values to other Terraform configurations (advanced)
# =============================================================================

output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.server.id
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.server.public_ip
}

output "instance_state" {
  description = "The state of the EC2 instance"
  value       = aws_instance.server.instance_state
}

output "connection_command" {
  description = "SSH command to connect (if you have the key)"
  value       = "ssh -i your-key.pem ec2-user@${aws_instance.server.public_ip}"
}
