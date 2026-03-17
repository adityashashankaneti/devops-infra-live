resource "aws_subnet" "this" {
  for_each = var.resources

  vpc_id                  = lookup(var.vpc_ids, each.value.vpc_name, null)
  cidr_block              = each.value.cidr_block
  availability_zone       = try(each.value.availability_zone, null)
  map_public_ip_on_launch = try(each.value.map_public_ip_on_launch, false)

  tags = merge(
    { Name = each.key, Project = var.project, ManagedBy = "terraform" },
    try(each.value.tags, {})
  )
}
