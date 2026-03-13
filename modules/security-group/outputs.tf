output "security_group_ids" {
  value = { for k, v in aws_security_group.this : k => v.id }
}

output "security_group_arns" {
  value = { for k, v in aws_security_group.this : k => v.arn }
}
