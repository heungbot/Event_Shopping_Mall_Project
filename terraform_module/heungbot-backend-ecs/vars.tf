# about APP
variable "APP_NAME" {
  default = "pipeline"
}

variable "AWS_REGION" {
  default = "ap-northeast-2"
}

variable "BUILD_NUMBER" {
  description = "this variable will be passed from jenkins"
}

variable "APP_ENV" {
  type    = string
  default = "prod"
}

variable "SIDE" {
  default = ["frontend", "backend"]
}

variable "SERVICE_FILE_PATH" {
  default = "/Users/bangdaeseonsaeng/Desktop/project/04_main_project/terraform_module/backend-ecs/container_definition.json"
}

# about VPC
variable "PRIVATE_SUBNET_IDS" {}

variable "MAIN_TARGET_GROUP_ARN" {}

variable "BACKEND_ECS_SERVICE_SG_ID" {}

variable "ECR_REPOSITORY_URL" {}

# backend 
variable "BACKEND_IMAGE" {
  description = "this variable will be passed from jenkins"
}

variable "BACKEND_CONTAINER_PORT" {}

variable "BACKEND_HOST_PORT" {}

variable "TASK_ROLE_ARN" {
  default = ""
}