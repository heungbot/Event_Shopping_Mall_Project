variable "FRONTEND_TAG" {
  type = map(string)
  default = {
    Name = "Frontend"
    env  = "prod"
  }
}

variable "MAIN_BUCKET_NAME" {}