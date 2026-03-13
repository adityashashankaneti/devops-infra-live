output "nat_gateway_ids" {
  value = { for k, v in aws_nat_gateway.this : k => v.id }
}

output "nat_gateway_public_ips" {
  value = { for k, v in aws_nat_gateway.this : k => v.public_ip }
}
