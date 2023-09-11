# about AWS
variable "AWS_REGION" {
  default = "ap-northeast-2"
}

# about APP
variable "APP_NAME" {
  default = "main-pipeline"
}

variable "APP_ENV" {
  type    = string
  default = "prod"
}

# about VPC
variable "VPC_CIDR" {
  description = "The cidr block for the VPC."
  default     = "10.10.0.0/16"
}

variable "PUBLIC_CIDR" {
  description = "list public subnet cidr"
  default     = ["10.10.0.0/24", "10.10.1.0/24"] # 0 ~ 63
}

variable "PRIVATE_CIDR" {
  description = "list private subnet cidr"
  default     = ["10.10.50.0/24", "10.10.51.0/24"] # 64 ~ 127
}

variable "CACHE_CIDR" {
  description = "list db subnet cidr"
  default     = ["10.10.100.0/24", "10.10.101.0/24"] # 128 ~ 191
}

variable "DB_CIDR" {
  description = "list db subnet cidr"
  default     = ["10.10.200.0/24", "10.10.201.0/24"] # 192 ~ 255
}



variable "AZ" {
  description = "list az"
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "SIDE" {
  default = ["frontend", "backend"]
}