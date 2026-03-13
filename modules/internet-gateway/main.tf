resource "aws_internet_gateway" "this" {
  for_each = var.resources

  vpc_id = var.vpc_ids[each.value.vpc_name]

  tags = merge(
    { Name = each.key, Project = var.project, ManagedBy = "terraform" },
    try(each.value.tags, {})
  )
}
