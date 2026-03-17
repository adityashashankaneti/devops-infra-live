resource "aws_route53_zone" "this" {
  for_each = var.resources

  name    = each.value.zone_name
  comment = try(each.value.comment, "Managed by DevOps AI")

  dynamic "vpc" {
    for_each = try(each.value.private_zone, false) ? [1] : []
    content {
      vpc_id = lookup(var.vpc_ids, each.value.vpc_name, null)
    }
  }

  tags = merge(
    { Name = each.key, Project = var.project, ManagedBy = "terraform" },
    try(each.value.tags, {})
  )
}

resource "aws_route53_record" "this" {
  for_each = { for item in local.all_records : "${item.zone_key}-${item.name}-${item.type}" => item }

  zone_id = aws_route53_zone.this[each.value.zone_key].zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = try(each.value.ttl, 300)
  records = each.value.records
}

locals {
  all_records = flatten([
    for zone_key, zone in var.resources : [
      for record in try(zone.records, []) : {
        zone_key = zone_key
        name     = record.name
        type     = record.type
        ttl      = try(record.ttl, 300)
        records  = record.values
      }
    ]
  ])
}
