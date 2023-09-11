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

variable "SIDE" {
  default = ["frontend", "backend"]
}

variable "APP_ENV" {
  type    = string
  default = "prod"
}

variable "VPC_ID" {}

variable "ADMIN_CIDR" {}

variable "BASTION_PORT" {}

variable "ECS_SERVICE_PORT" {}

variable "DB_PORT" {}

variable "CACHE_PORT" {}