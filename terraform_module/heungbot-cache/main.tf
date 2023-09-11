# 약 일주일 간의 running time
# 데이터가 자주 변경되지 않고, DB 잦은 access를 처리
# Redis : 복잡한 데이터 or 자주 변경되는 데이터
# Memcached : 동일 데이터에 대한 access가 많은 경우 (채택)


resource "aws_elasticache_cluster" "main" {
  cluster_id      = var.CACHE_CLUSTER_ID
  engine          = "memcached"
  node_type       = var.CACHE_NODE_TYPE # cache.t2.micro
  num_cache_nodes = var.CACHE_NODE_NUM  # should highed than 1 to use cross az mode
  az_mode         = var.AZ_MODE
  #   parameter_group_name = "default.memcached1.4"
  parameter_group_name = var.CACHE_PARAMETER_GROUP_NAME # default.memcached1.4
  port                 = var.CACHE_PORT
  subnet_group_name    = var.DB_SUBNET_GROUP_NAME
  security_group_ids   = [var.CACHE_SG_ID]
}