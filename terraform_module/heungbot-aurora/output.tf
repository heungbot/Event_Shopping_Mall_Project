output "AURORA_ENDPOINT" {
  value = aws_rds_cluster.aurora_mysql_cluster.endpoint
}

output "AURORA_READER_ENDPOINT" {
  value = aws_rds_cluster.aurora_mysql_cluster.reader_endpoint
}

output "AURORA_CLUSTER_ARN" {
  value = aws_rds_cluster.aurora_mysql_cluster.arn
}

output "AURORA_CLUSTER_ID" {
  value = aws_rds_cluster.aurora_mysql_cluster.id
}