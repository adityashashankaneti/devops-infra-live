# ── Route Tables ──────────────────────────────────────────────────────────────
# Each route table has:
#   - A VPC association
#   - One or more routes (0.0.0.0/0 → IGW for public, 0.0.0.0/0 → NAT for private)
#   - Subnet associations

resource "aws_route_table" "this" {
  for_each = var.resources

  vpc_id = lookup(var.vpc_ids, each.value.vpc_name, null)

  tags = merge(
    { Name = each.key, Project = var.project, ManagedBy = "terraform" },
    try(each.value.tags, {})
  )
}

# ── Routes ────────────────────────────────────────────────────────────────────
locals {
  all_routes = flatten([
    for rt_key, rt in var.resources : [
      for idx, route in try(rt.routes, []) : {
        rt_key       = rt_key
        route_key    = "${rt_key}-${idx}"
        cidr_block   = route.cidr_block
        gateway_type = route.gateway_type        # "igw" or "nat"
        gateway_name = route.gateway_name         # name of the IGW or NAT GW
      }
    ]
  ])

  all_associations = flatten([
    for rt_key, rt in var.resources : [
      for subnet_name in try(rt.subnet_associations, []) : {
        rt_key      = rt_key
        assoc_key   = "${rt_key}-${subnet_name}"
        subnet_name = subnet_name
      }
    ]
  ])
}

resource "aws_route" "this" {
  for_each = { for r in local.all_routes : r.route_key => r }

  route_table_id         = aws_route_table.this[each.value.rt_key].id
  destination_cidr_block = each.value.cidr_block

  gateway_id     = each.value.gateway_type == "igw" ? lookup(var.igw_ids, each.value.gateway_name, null) : null
  nat_gateway_id = each.value.gateway_type == "nat" ? lookup(var.nat_gateway_ids, each.value.gateway_name, null) : null
}

# ── Subnet Associations ──────────────────────────────────────────────────────
resource "aws_route_table_association" "this" {
  for_each = { for a in local.all_associations : a.assoc_key => a }

  route_table_id = aws_route_table.this[each.value.rt_key].id
  subnet_id      = lookup(var.subnet_ids, each.value.subnet_name, null)
}
