variable "APP_NAME" {
  default = "main-pipeline"
}

variable "APP_ENV" {
  type    = string
  default = "prod"
}

variable "VPC_ID" {}

variable "PUBLIC_SUBNET_IDS" {}

variable "PUBLIC_KEY_PATH" {}

variable "BASTION_AMI" {}

variable "BASTION_TYPE" {}

variable "BASTION_SG_ID" {}