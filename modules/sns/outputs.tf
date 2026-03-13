output "topic_arns" {
  value = { for k, v in aws_sns_topic.this : k => v.arn }
}
