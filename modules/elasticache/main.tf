resource "aws_elasticache_cluster" "this" {
  for_each = var.resources

  cluster_id           = each.key
  engine               = try(each.value.engine, "redis")
  node_type            = try(each.value.node_type, "cache.t3.micro")
  num_cache_nodes      = try(each.value.num_cache_nodes, 1)
  port                 = try(each.value.port, each.value.engine == "memcached" ? 11211 : 6379)
  parameter_group_name = try(each.value.parameter_group_name, null)
  subnet_group_name    = try(aws_elasticache_subnet_group.this[each.key].name, null)
  security_group_ids   = try([for sg in each.value.security_groups : var.security_group_ids[sg]], [])

  tags = merge(
    { Name = each.key, Project = var.project, ManagedBy = "terraform" },
    try(each.value.tags, {})
  )
}

resource "aws_elasticache_subnet_group" "this" {
  for_each = { for k, v in var.resources : k => v if try(v.subnet_names, null) != null }

  name       = "${each.key}-subnet-group"
  subnet_ids = [for s in each.value.subnet_names : lookup(var.subnet_ids, s, null)]
}
