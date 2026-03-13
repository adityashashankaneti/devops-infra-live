resource "aws_sns_topic" "this" {
  for_each = var.resources

  name         = each.key
  display_name = try(each.value.display_name, each.key)

  kms_master_key_id = try(each.value.kms_key_id, "alias/aws/sns")

  tags = merge(
    { Name = each.key, Project = var.project, ManagedBy = "terraform" },
    try(each.value.tags, {})
  )
}

# ── Resource-based topic policy ──────────────────────────────────────────────
resource "aws_sns_topic_policy" "this" {
  for_each = { for k, v in var.resources : k => v if try(v.topic_policy, null) != null }

  arn = aws_sns_topic.this[each.key].arn

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = each.value.topic_policy.statements
  })
}

resource "aws_sns_topic_subscription" "this" {
  for_each = { for item in local.all_subs : "${item.topic_key}-${item.protocol}-${item.endpoint}" => item }

  topic_arn = aws_sns_topic.this[each.value.topic_key].arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint
}

locals {
  all_subs = flatten([
    for topic_key, topic in var.resources : [
      for sub in try(topic.subscriptions, []) : {
        topic_key = topic_key
        protocol  = sub.protocol
        endpoint  = sub.endpoint
      }
    ]
  ])
}
