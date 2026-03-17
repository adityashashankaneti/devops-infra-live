resource "aws_eip" "this" {
  for_each = var.resources

  domain = "vpc"

  tags = { Name = "${each.key}-eip", Project = var.project, ManagedBy = "terraform" }
}

resource "aws_nat_gateway" "this" {
  for_each = var.resources

  allocation_id = aws_eip.this[each.key].id
  subnet_id     = lookup(var.subnet_ids, each.value.subnet_name, null)

  tags = merge(
    { Name = each.key, Project = var.project, ManagedBy = "terraform" },
    try(each.value.tags, {})
  )

  depends_on = [aws_eip.this]
}
