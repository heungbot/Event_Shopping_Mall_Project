# ####### RDS #######
# # Read Replica : "ASYCN" used for "SELECT" query not INSERT, UPDATE.... 
# # Read Replica can be setup as Multi AZ for DR

# # and At same Region for RDS, Network Cost is free
# # No SSH connection. IAM Role and Security Group

# # rds cluster(multi az) : 여러개의 node 사용 - REAL Production 환경
# # rds multi az instance : primary instance & replica 간의 latency 발생 가능(ASYNC) - Dev or Small Production(장애 발생 시, 약간의 data loss 감수)

# module "rds-master" {
#   source  = "terraform-aws-modules/rds/aws"
#   version = "5.9.0"

#   identifier = var.MASTER_DB_IDENTIFIER # name of rds instance

#   engine         = "mysql"
#   engine_version = "8.0.32"
#   instance_class = "db.t3.small" # rds cluster인지 multi AZ instance인지에 따라 호환되는 type 다름. 이는 console에서 파악.
#   # 그것 보다, cluster or db instance 인지 어떻게 선택하냐
#   allocated_storage     = 10
#   max_allocated_storage = 20

#   db_name  = "heungbot_rds_db"
#   username = var.MASTER_USERNAME
#   port     = var.DB_PORT

#   iam_database_authentication_enabled = true

#   vpc_security_group_ids = var.DB_SG_IDS

#   maintenance_window              = "Mon:00:00-Mon:03:00" # 유지 관리 작업 등을 수행할 수 있는 시간 범위
#   backup_window                   = "03:00-06:00"         # automated backup run time in UTC
#   enabled_cloudwatch_logs_exports = ["general"]

#   backup_retention_period = 1
#   skip_final_snapshot     = true

#   # Enhanced Monitoring - see example for details on how to create the role
#   # by yourself, in case you don't want to create it automatically

#   ## Enhanced Monitoring Part
#   #   monitoring_interval    = "30"
#   #   monitoring_role_name   = "MyRDSMonitoringRole"
#   #   create_monitoring_role = true

#   tags = {
#     Owner = "heungbot"
#     Env   = "prod"
#   }

#   # DB subnet group
#   # create_db_subnet_group = true # 이렇게 생성하는 건 그닥인 것 같은데 vpc 만들 때, db subnet group을 하나 만드는 것이 좋을듯(github example도 그렇게 함)
#   db_subnet_group_name = var.DB_SUBNET_GROUP_NAME # 이렇게 하면 또 replica에서는 subnet gruop name 지정 안 하는 것 같음.
#   multi_az             = true

#   # DB parameter group
#   family = "mysql8.0"

#   # DB option group
#   major_engine_version = "8.0"

#   # Database Deletion Protection
#   deletion_protection = false # if real production, should set "true"

#   parameters = [
#     {
#       name  = "character_set_client"
#       value = "utf8mb4"
#     },
#     {
#       name  = "character_set_server"
#       value = "utf8mb4"
#     }
#   ]

#   options = [
#     {
#       option_name = "MARIADB_AUDIT_PLUGIN"

#       option_settings = [
#         {
#           name  = "SERVER_AUDIT_EVENTS"
#           value = "CONNECT"
#         },
#         {
#           name  = "SERVER_AUDIT_FILE_ROTATIONS"
#           value = "37"
#         },
#       ]
#     },
#   ]
# }

# module "rds-replica" {
#   source              = "terraform-aws-modules/rds/aws"
#   version             = "5.9.0"
#   replicate_source_db = var.MASTER_DB_IDENTIFIER

#   identifier = "${var.MASTER_DB_IDENTIFIER}-replica" # name of rds instance

#   engine         = "mysql"
#   engine_version = "8.0.32"
#   instance_class = "db.t3.small"

#   allocated_storage     = 10
#   max_allocated_storage = 20

#   port = var.DB_PORT

#   iam_database_authentication_enabled = true

#   vpc_security_group_ids = var.DB_SG_IDS

#   maintenance_window              = "Mon:00:00-Mon:03:00" # 유지 관리 작업 등을 수행할 수 있는 시간 범위
#   backup_window                   = "03:00-06:00"         # automated backup run time in UTC
#   enabled_cloudwatch_logs_exports = ["general"]

#   backup_retention_period = 1
#   skip_final_snapshot     = true

#   tags = {
#     Owner = "heungbot"
#     Env   = "prod"
#   }

#   # DB subnet group = 지정해주지 않아도 됨. replica니까!
#   multi_az = false

#   # DB parameter group
#   family = "mysql8.0"

#   # DB option group
#   major_engine_version = "8.0"

#   # Database Deletion Protection
#   deletion_protection = false # if real production, should set "true"

#   parameters = [
#     {
#       name  = "character_set_client"
#       value = "utf8mb4"
#     },
#     {
#       name  = "character_set_server"
#       value = "utf8mb4"
#     }
#   ]

#   options = [
#     {
#       option_name = "MARIADB_AUDIT_PLUGIN"

#       option_settings = [
#         {
#           name  = "SERVER_AUDIT_EVENTS"
#           value = "CONNECT"
#         },
#         {
#           name  = "SERVER_AUDIT_FILE_ROTATIONS"
#           value = "37"
#         },
#       ]
#     },
#   ]
# }

####### AURORA MYSQL #######

resource "aws_rds_cluster_parameter_group" "heungbot_aurora_cluster_parameter_group" {
  name   = "heungbot-aurora-cluster-parameter-group"
  family = var.PARAMETER_GROUP_FAMILY
}

resource "aws_rds_cluster" "aurora_mysql_cluster" {
  cluster_identifier = var.CLUSTER_IDENTIFIER
  engine             = "aurora-mysql"
  engine_version     = "5.7.mysql_aurora.2.11.2"
  port = var.DB_PORT
  availability_zones              = ["${var.AZ[0]}", "${var.AZ[1]}"] # az from heungbot-base module
  database_name                   = "heungbot_db"
  master_username                 = var.MASTER_USERNAME
  master_password                 = var.MASTER_USER_PASSWORD # Only printable ASCII characters besides '/', '@', '"', ' ' may be used
  backup_retention_period         = 1             # 1-35
  preferred_backup_window         = "18:00-22:00" # UTC. +9 = 03 ~ 07
  preferred_maintenance_window    = "wed:04:00-wed:04:30"
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.heungbot_aurora_cluster_parameter_group.name # Cluster에 속할 db instance에 대한 parameter group에 대한 기본값 설정 - 이는 cluster_instance level에서 재정의 가능
  db_subnet_group_name            = var.DB_SUBNET_GROUP_NAME                                                     # multi az cluster
  vpc_security_group_ids          = [var.DB_SG_ID]                                                                # list
  skip_final_snapshot             = true

  tags = {
    Name        = "${var.APP_NAME}-aurora-mysql-cluster"
    Environment = var.APP_ENV
    ManageBy    = "terraform"
  }
}


resource "aws_rds_cluster_instance" "aurora_instance" {
  count              = length(var.DB_SUBNET_IDS) # db subnet ids = aws_subnet.db.*.id
  identifier         = "${var.CLUSTER_IDENTIFIER}-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.aurora_mysql_cluster.id
  instance_class     = "db.t3.small"

  engine         = aws_rds_cluster.aurora_mysql_cluster.engine
  engine_version = aws_rds_cluster.aurora_mysql_cluster.engine_version

  availability_zone          = element(var.AZ, count.index)
  db_subnet_group_name       = var.DB_SUBNET_GROUP_NAME
  auto_minor_version_upgrade = true

  tags = {
    Name        = "${var.APP_NAME}-aurora-instance-${count.index + 1}"
    Environment = var.APP_ENV
    ManageBy    = "terraform"
  }


  # promotion_tier = 0 # default = 0 장애발생 시, aurora replica가 master로 승격하기 위한 우선순위 값.
  # publicly_accessible  = false : 의미 없을듯 어차피 private subnet 내에 배치되므로

  # # enhanced monitoring
  # performance_insights_enabled = true
  # performance_insights_kms_key_id = var.KMS_KEY_ARN
  # performance_insights_retention_period = 7 # default = 7 | valid_value = 7, 31 ,732
}

resource "aws_appautoscaling_target" "aurora_replicas_target" {
  service_namespace  = "rds"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  resource_id        = "cluster:${aws_rds_cluster.aurora_mysql_cluster.id}"
  min_capacity       = 1
  max_capacity       = 5
}

resource "aws_appautoscaling_policy" "aurora_replicas_target" {
  name               = "cpu-auto-scaling"
  service_namespace  = aws_appautoscaling_target.aurora_replicas_target.service_namespace
  scalable_dimension = aws_appautoscaling_target.aurora_replicas_target.scalable_dimension
  resource_id        = aws_appautoscaling_target.aurora_replicas_target.resource_id
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "RDSReaderAverageCPUUtilization"
    }

    target_value       = 70
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}