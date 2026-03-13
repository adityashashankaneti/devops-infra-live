#trivy:ignore:AVD-AWS-0089
resource "aws_s3_bucket" "this" {
  for_each = var.resources

  bucket        = try(each.value.bucket_name, "${var.project}-${each.key}")
  force_destroy = try(each.value.force_destroy, false)

  tags = merge(
    { Name = each.key, Project = var.project, ManagedBy = "terraform" },
    try(each.value.tags, {})
  )
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = { for k, v in var.resources : k => v if try(v.versioning, false) }

  bucket = aws_s3_bucket.this[each.key].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = var.resources

  bucket = aws_s3_bucket.this[each.key].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = try(each.value.sse_algorithm, "aws:kms")
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = var.resources

  bucket                  = aws_s3_bucket.this[each.key].id
  block_public_acls       = try(each.value.block_public_acls, true)
  block_public_policy     = try(each.value.block_public_policy, true)
  ignore_public_acls      = try(each.value.ignore_public_acls, true)
  restrict_public_buckets = try(each.value.restrict_public_buckets, true)
}

# ── Resource-based bucket policy (for cross-service access) ──────────────────
# Claude generates bucket_policy.statements[] from canvas connections
# e.g. CloudFront→S3 or Lambda→S3 connections
resource "aws_s3_bucket_policy" "this" {
  for_each = { for k, v in var.resources : k => v if try(v.bucket_policy, null) != null }

  bucket = aws_s3_bucket.this[each.key].id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = each.value.bucket_policy.statements
  })

  depends_on = [aws_s3_bucket_public_access_block.this]
}
