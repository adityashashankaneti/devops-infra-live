output "cluster_arns" {
  value = { for k, v in aws_ecs_cluster.this : k => v.arn }
}

output "cluster_ids" {
  value = { for k, v in aws_ecs_cluster.this : k => v.id }
}
