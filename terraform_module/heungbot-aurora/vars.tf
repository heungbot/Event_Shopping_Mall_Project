// variable "AWS_REGION" {}

variable "AZ" {
  description = "list az"
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "APP_NAME" {
  default = "main-pipeline"
}

variable "APP_ENV" {
  type    = string
  default = "prod"
}

variable "DB_SUBNET_GROUP_NAME" {}

variable "DB_SG_ID" {}

variable "DB_SUBNET_IDS" {}

variable "DB_PORT" {}

variable "MASTER_USERNAME" {}

variable "MASTER_USER_PASSWORD" {}

variable "CLUSTER_IDENTIFIER" {
  default = "heungbot-aurora-cluster"
}

variable "PARAMETER_GROUP_FAMILY" {}

# variable "MASTER_DB_IDENTIFIER" {}

