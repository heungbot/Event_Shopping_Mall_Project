output "VPC_ID" {
  value = aws_vpc.main.id
}

output "PUBLIC_SUBNET_IDS" {
  description = "public subnet's id list"
  value       = aws_subnet.public.*.id
}

output "PRIVATE_SUBNET_IDS" {
  description = "private subnet's id list"
  value       = aws_subnet.private.*.id
}

output "DB_SUBNET_GROUP_NAME" {
  value = aws_db_subnet_group.rds-subnet-group.name
}

output "CACHE_SUBNET_GROUP_NAME" {
  value = aws_elasticache_subnet_group.cache-subnet-group.name
}

output "DB_SUBNET_IDS" {
  value = flatten(tolist(aws_subnet.db.*.id))
}