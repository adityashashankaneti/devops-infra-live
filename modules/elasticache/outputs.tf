output "cluster_ids" {
  value = { for k, v in aws_elasticache_cluster.this : k => v.id }
}

output "cache_endpoints" {
  value = { for k, v in aws_elasticache_cluster.this : k => v.cache_nodes }
}
