resource "aws_security_group" "this" {
  for_each = var.resources

  name        = each.key
  description = try(each.value.description, "Managed by DevOps AI")
  vpc_id      = lookup(var.vpc_ids, each.value.vpc_name, null)

  # Default egress: allow all outbound
  dynamic "egress" {
    for_each = try(each.value.egress_rules, [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }])
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = try(egress.value.cidr_blocks, ["0.0.0.0/0"])
      description = try(egress.value.description, null)
    }
  }

  tags = merge(
    { Name = each.key, Project = var.project, ManagedBy = "terraform" },
    try(each.value.tags, {})
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ── CIDR-based ingress rules ────────────────────────────────────────────────
locals {
  cidr_rules = flatten([
    for sg_key, sg in var.resources : [
      for idx, rule in try(sg.ingress_rules, []) : {
        sg_key      = sg_key
        rule_key    = "${sg_key}-cidr-${idx}"
        from_port   = rule.from_port
        to_port     = rule.to_port
        protocol    = rule.protocol
        cidr_blocks = try(rule.cidr_blocks, [])
        description = try(rule.description, null)
      } if try(rule.source_security_group, null) == null
    ]
  ])

  sg_rules = flatten([
    for sg_key, sg in var.resources : [
      for idx, rule in try(sg.ingress_rules, []) : {
        sg_key                 = sg_key
        rule_key               = "${sg_key}-sg-${idx}"
        from_port              = rule.from_port
        to_port                = rule.to_port
        protocol               = rule.protocol
        source_security_group  = rule.source_security_group
        description            = try(rule.description, null)
      } if try(rule.source_security_group, null) != null
    ]
  ])
}

resource "aws_security_group_rule" "cidr_ingress" {
  for_each = { for r in local.cidr_rules : r.rule_key => r }

  type              = "ingress"
  security_group_id = aws_security_group.this[each.value.sg_key].id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  description       = each.value.description
}

# ── SG-to-SG ingress rules (cross-reference by name) ────────────────────────
resource "aws_security_group_rule" "sg_ingress" {
  for_each = { for r in local.sg_rules : r.rule_key => r }

  type                     = "ingress"
  security_group_id        = aws_security_group.this[each.value.sg_key].id
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  source_security_group_id = aws_security_group.this[each.value.source_security_group].id
  description              = each.value.description
}
