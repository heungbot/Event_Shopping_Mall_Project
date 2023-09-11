variable "DOMAIN_NAME" {
  type        = string
  description = "The domain name for the website."
}

variable "FRONTEND_DIR_PATH" {}

# variable "MAIN_INDEX_HTML_PATH" {}

variable "BUCKET_ORIGIN_GROUP_ID" {
  type    = string
  default = "heungbot-origin-group-id"
}

variable "MAIN_BUCKET_REGIONAL_DOMAIN_NAME" {}

variable "FRONTEND_TAG" {
  type = map(string)
  default = {
    Name = "Frontend"
    env  = "prod"
  }
}