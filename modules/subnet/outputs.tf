output "subnet_ids" {
  description = "Map of subnet name → subnet ID"
  value       = { for k, v in aws_subnet.this : k => v.id }
}

output "subnet_arns" {
  value = { for k, v in aws_subnet.this : k => v.arn }
}
