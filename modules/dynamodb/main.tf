resource "aws_dynamodb_table" "this" {
  for_each = var.resources

  name         = each.key
  billing_mode = try(each.value.billing_mode, "PAY_PER_REQUEST")
  hash_key     = each.value.hash_key
  range_key    = try(each.value.range_key, null)

  dynamic "attribute" {
    for_each = each.value.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  point_in_time_recovery {
    enabled = try(each.value.point_in_time_recovery, true)
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(
    { Name = each.key, Project = var.project, ManagedBy = "terraform" },
    try(each.value.tags, {})
  )
}
