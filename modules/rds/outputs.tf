output "db_instance_ids" {
  value = { for k, v in aws_db_instance.this : k => v.id }
}

output "db_endpoints" {
  value = { for k, v in aws_db_instance.this : k => v.endpoint }
}

output "db_arns" {
  value = { for k, v in aws_db_instance.this : k => v.arn }
}
