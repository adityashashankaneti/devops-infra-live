resource "aws_sqs_queue" "this" {
  for_each = var.resources

  name                       = each.key
  delay_seconds              = try(each.value.delay_seconds, 0)
  max_message_size           = try(each.value.max_message_size, 262144)
  message_retention_seconds  = try(each.value.message_retention_seconds, 345600)
  visibility_timeout_seconds = try(each.value.visibility_timeout_seconds, 30)
  sqs_managed_sse_enabled    = try(each.value.sse_enabled, true)

  tags = merge(
    { Name = each.key, Project = var.project, ManagedBy = "terraform" },
    try(each.value.tags, {})
  )
}

# ── Resource-based queue policy ──────────────────────────────────────────────
# Claude generates queue_policy.statements[] from connections (e.g. SNS→SQS)
resource "aws_sqs_queue_policy" "this" {
  for_each = { for k, v in var.resources : k => v if try(v.queue_policy, null) != null }

  queue_url = aws_sqs_queue.this[each.key].url

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = each.value.queue_policy.statements
  })
}
