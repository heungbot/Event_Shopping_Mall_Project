output "CACHE_CLUSTER_ARN" {
  value = aws_elasticache_cluster.main.arn
}
output "CACHE_CLUSTER_ADDRESS" {
  value = aws_elasticache_cluster.main.cluster_address
}
output "CACHE_CLUSTER_ENDPOINT" {
  value = aws_elasticache_cluster.main.configuration_endpoint
}
