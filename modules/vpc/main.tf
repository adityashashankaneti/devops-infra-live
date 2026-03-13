resource "aws_vpc" "this" {
  for_each = var.resources

  cidr_block           = each.value.cidr_block
  enable_dns_hostnames = try(each.value.enable_dns_hostnames, true)
  enable_dns_support   = try(each.value.enable_dns_support, true)

  tags = merge(
    { Name = each.key, Project = var.project, ManagedBy = "terraform" },
    try(each.value.tags, {})
  )
}
