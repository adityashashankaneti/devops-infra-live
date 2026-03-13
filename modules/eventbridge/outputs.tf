output "rule_arns" {
  value = { for k, v in aws_cloudwatch_event_rule.this : k => v.arn }
}

output "event_bus_arns" {
  value = { for k, v in aws_cloudwatch_event_bus.custom : k => v.arn }
}
