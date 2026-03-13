resource "aws_lb" "this" {
  for_each = var.resources

  name               = each.key
  internal           = try(each.value.internal, false)
  load_balancer_type = try(each.value.type, "application")

  security_groups = try(
    [for sg in each.value.security_groups : var.security_group_ids[sg]],
    []
  )

  subnets = [for s in each.value.subnet_names : var.subnet_ids[s]]

  enable_deletion_protection = try(each.value.deletion_protection, false)

  tags = merge(
    { Name = each.key, Project = var.project, ManagedBy = "terraform" },
    try(each.value.tags, {})
  )
}

resource "aws_lb_target_group" "this" {
  for_each = { for k, v in var.resources : k => v if try(v.target_group, null) != null }

  name        = "${each.key}-tg"
  port        = try(each.value.target_group.port, 80)
  protocol    = try(each.value.target_group.protocol, "HTTP")
  vpc_id      = var.vpc_ids[each.value.vpc_name]
  target_type = try(each.value.target_group.target_type, "instance")

  health_check {
    path                = try(each.value.target_group.health_check_path, "/")
    healthy_threshold   = try(each.value.target_group.healthy_threshold, 3)
    unhealthy_threshold = try(each.value.target_group.unhealthy_threshold, 3)
  }

  tags = { Name = "${each.key}-tg", Project = var.project, ManagedBy = "terraform" }
}

resource "aws_lb_listener" "this" {
  for_each = { for k, v in var.resources : k => v if try(v.target_group, null) != null }

  load_balancer_arn = aws_lb.this[each.key].arn
  port              = try(each.value.listener_port, 80)
  protocol          = try(each.value.listener_protocol, "HTTP")

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }
}
