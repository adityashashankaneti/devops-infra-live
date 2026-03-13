resource "aws_ecs_cluster" "this" {
  for_each = var.resources

  name = each.key

  setting {
    name  = "containerInsights"
    value = try(each.value.container_insights, "enabled")
  }

  tags = merge(
    { Name = each.key, Project = var.project, ManagedBy = "terraform" },
    try(each.value.tags, {})
  )
}
