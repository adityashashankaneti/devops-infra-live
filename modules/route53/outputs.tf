output "zone_ids" {
  value = { for k, v in aws_route53_zone.this : k => v.zone_id }
}

output "name_servers" {
  value = { for k, v in aws_route53_zone.this : k => v.name_servers }
}
