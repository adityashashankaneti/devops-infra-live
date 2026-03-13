resource "aws_cloudwatch_event_bus" "custom" {
  for_each = { for k, v in var.resources : k => v if try(v.custom_bus, false) }

  name = each.key

  tags = { Name = each.key, Project = var.project, ManagedBy = "terraform" }
}

resource "aws_cloudwatch_event_rule" "this" {
  for_each = var.resources

  name           = each.key
  description    = try(each.value.description, "Managed by DevOps AI")
  event_bus_name = try(each.value.custom_bus, false) ? aws_cloudwatch_event_bus.custom[each.key].name : "default"

  event_pattern = try(jsonencode(each.value.event_pattern), null)

  schedule_expression = try(each.value.schedule_expression, null)

  tags = merge(
    { Name = each.key, Project = var.project, ManagedBy = "terraform" },
    try(each.value.tags, {})
  )
}
