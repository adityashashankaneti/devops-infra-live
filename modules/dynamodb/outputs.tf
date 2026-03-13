output "table_arns" {
  value = { for k, v in aws_dynamodb_table.this : k => v.arn }
}

output "table_ids" {
  value = { for k, v in aws_dynamodb_table.this : k => v.id }
}
