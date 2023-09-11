### BASE(VPC) ### 
module "heungbot-base" {
  source = "./heungbot-base"
}

module "heungbot-sg" {
  source       = "./heungbot-sg"
  depends_on   = [module.heungbot-base]
  VPC_ID       = module.heungbot-base.VPC_ID
  ADMIN_CIDR   = var.ADMIN_CIDR
  BASTION_PORT = var.BASTION_PORT
  # ALB_PORT = 
  ECS_SERVICE_PORT = var.ECS_SERVICE_PORT
  DB_PORT          = var.DB_PORT
  CACHE_PORT       = var.CACHE_PORT
}

module "heungbot-bastion" {
  source            = "./heungbot-bastion"
  depends_on        = [module.heungbot-sg]
  VPC_ID            = module.heungbot-base.VPC_ID
  PUBLIC_SUBNET_IDS = module.heungbot-base.PUBLIC_SUBNET_IDS
  PUBLIC_KEY_PATH   = var.PUBLIC_KEY_PATH
  BASTION_AMI       = var.BASTION_AMI
  BASTION_TYPE      = var.BASTION_TYPE
  BASTION_SG_ID     = module.heungbot-sg.BASTION_SG_ID

}

### FRONTEND ### 
module "heungbot-frontend-s3" { # cf origin 1
  source           = "./heungbot-frontend-s3"
  MAIN_BUCKET_NAME = var.MAIN_BUCKET_NAME
}

module "heungbot-frontend-alb" { # cf origin 2
  source                 = "./heungbot-frontend-alb"
  depends_on             = [module.heungbot-sg]
  VPC_ID                 = module.heungbot-base.VPC_ID
  PUBLIC_SUBNET_IDS      = module.heungbot-base.PUBLIC_SUBNET_IDS
  HEALTH_CHECK_PATH      = "/"
  JENKINS_WORKSPACE_PATH = var.JENKINS_WORKSPACE_PATH
  ALB_SG_ID              = module.heungbot-sg.ALB_SG_ID
}

module "heungbot-frontend-cloudfront" {
  source     = "./heungbot-frontend-cloudfront"
  # depends_on = [module.heungbot-frontend-alb]
  # depends_on               = [module.heungbot-base] # why?
  MAIN_BUCKET_REGIONAL_DOMAIN_NAME = module.heungbot-frontend-s3.MAIN_BUCKET_REGIONAL_DOMAIN_NAME
  DOMAIN_NAME                      = var.DOMAIN_NAME
  FRONTEND_DIR_PATH                = var.FRONTEND_DIR_PATH
}

module "heungbot-oac" { # cycle error 때문에 별도의 모듈로 설정
  source              = "./heungbot-frontend-oac"
  depends_on          = [module.heungbot-frontend-s3, module.heungbot-frontend-cloudfront]
  MAIN_BUCKET_ID      = module.heungbot-frontend-s3.MAIN_BUCKET_ID
  MAIN_BUCKET_ARN     = module.heungbot-frontend-s3.MAIN_BUCKET_ARN
  MAIN_CLOUDFRONT_ARN = module.heungbot-frontend-cloudfront.MAIN_DISTRIBUTION_ARN
}

### BACKEND ###
module "heungbot-cache" {
  source                     = "./heungbot-cache"
  depends_on                 = [module.heungbot-sg]
  DB_SUBNET_GROUP_NAME       = module.heungbot-base.CACHE_SUBNET_GROUP_NAME
  AZ_MODE                    = "cross-az"
  CACHE_SG_ID                = module.heungbot-sg.CACHE_SG_ID
  CACHE_PARAMETER_GROUP_NAME = "default.memcached1.6"
  CACHE_CLUSTER_ID           = "heungbot-cache"
  CACHE_PORT                 = var.CACHE_PORT
  CACHE_NODE_NUM             = 2
  CACHE_NODE_TYPE            = "cache.t2.micro"
}

### DB ###
module "heungbot-aurora" {
  source                 = "./heungbot-aurora"
  depends_on             = [module.heungbot-sg]
  DB_PORT                = var.DB_PORT
  DB_SUBNET_GROUP_NAME   = module.heungbot-base.DB_SUBNET_GROUP_NAME
  DB_SG_ID               = module.heungbot-sg.RDS_SG_ID
  DB_SUBNET_IDS          = module.heungbot-base.DB_SUBNET_IDS
  MASTER_USERNAME        = var.MASTER_USERNAME
  MASTER_USER_PASSWORD   = var.MASTER_USER_PASSWORD
  PARAMETER_GROUP_FAMILY = "aurora-mysql5.7"
}

module "heungbot-ecr" {
  source = "./heungbot-ecr"
}

module "heungbot-backend-ecs" {
  source                    = "./heungbot-backend-ecs"
  depends_on                = [module.heungbot-aurora, module.heungbot-ecr]
  BUILD_NUMBER              = var.BUILD_NUMBER
  BACKEND_IMAGE             = var.BACKEND_IMAGE
  BACKEND_CONTAINER_PORT    = var.BACKEND_CONTAINER_PORT
  BACKEND_HOST_PORT         = var.BACKEND_HOST_PORT
  BACKEND_ECS_SERVICE_SG_ID = module.heungbot-sg.ECS_SERVICE_SG_ID
  PRIVATE_SUBNET_IDS        = module.heungbot-base.PRIVATE_SUBNET_IDS
  MAIN_TARGET_GROUP_ARN     = module.heungbot-frontend-alb.main_target_group_arn
  ECR_REPOSITORY_URL        = module.heungbot-ecr.ECR_REPOSITORY_URL
  SERVICE_FILE_PATH         = var.SERVICE_FILE_PATH
}