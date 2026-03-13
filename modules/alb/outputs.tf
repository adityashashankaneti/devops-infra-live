output "lb_arns" {
  value = { for k, v in aws_lb.this : k => v.arn }
}

output "lb_dns_names" {
  value = { for k, v in aws_lb.this : k => v.dns_name }
}

output "target_group_arns" {
  value = { for k, v in aws_lb_target_group.this : k => v.arn }
}
