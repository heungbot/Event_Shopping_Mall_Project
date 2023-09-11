variable "APP_NAME" {
  default = "main-pipeline"
}

variable "ALB_PORTS" {
  type = map(list(string))
  default = {
    80  = ["0.0.0.0/0"]
    443 = ["0.0.0.0/0"]
  }
}

variable "APP_ENV" {
  type    = string
  default = "prod"
}


variable "SIDE" {
  default = ["frontend", "backend"]
}


variable "VPC_ID" {}

variable "PUBLIC_SUBNET_IDS" {}

variable "JENKINS_WORKSPACE_PATH" {}

variable "HEALTH_CHECK_PATH" {}

variable "ALB_SG_ID" {}