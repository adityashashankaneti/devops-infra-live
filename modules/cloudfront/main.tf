resource "aws_cloudfront_distribution" "this" {
  for_each = var.resources

  enabled         = try(each.value.enabled, true)
  is_ipv6_enabled = try(each.value.ipv6, true)
  comment         = try(each.value.comment, "Managed by DevOps AI")

  origin {
    domain_name = each.value.origin_domain
    origin_id   = "${each.key}-origin"

    dynamic "custom_origin_config" {
      for_each = try(each.value.origin_type, "custom") == "custom" ? [1] : []
      content {
        http_port              = try(each.value.origin_http_port, 80)
        https_port             = try(each.value.origin_https_port, 443)
        origin_protocol_policy = try(each.value.origin_protocol, "https-only")
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }

    dynamic "s3_origin_config" {
      for_each = try(each.value.origin_type, "custom") == "s3" ? [1] : []
      content {
        origin_access_identity = try(each.value.origin_access_identity, "")
      }
    }
  }

  default_cache_behavior {
    allowed_methods        = try(each.value.allowed_methods, ["GET", "HEAD"])
    cached_methods         = try(each.value.cached_methods, ["GET", "HEAD"])
    target_origin_id       = "${each.key}-origin"
    viewer_protocol_policy = try(each.value.viewer_protocol_policy, "redirect-to-https")

    forwarded_values {
      query_string = try(each.value.forward_query_string, false)
      cookies {
        forward = try(each.value.forward_cookies, "none")
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = merge(
    { Name = each.key, Project = var.project, ManagedBy = "terraform" },
    try(each.value.tags, {})
  )
}
