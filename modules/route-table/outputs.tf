output "route_table_ids" {
  description = "Map of route table name → route table ID"
  value       = { for k, v in aws_route_table.this : k => v.id }
}
