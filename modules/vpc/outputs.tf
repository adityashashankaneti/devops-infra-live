output "vpc_ids" {
  description = "Map of VPC name → VPC ID"
  value       = { for k, v in aws_vpc.this : k => v.id }
}

output "vpc_cidr_blocks" {
  description = "Map of VPC name → CIDR block"
  value       = { for k, v in aws_vpc.this : k => v.cidr_block }
}
