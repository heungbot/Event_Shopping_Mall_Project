##### 01 MAIN BUCKET ##### 
resource "aws_s3_bucket" "main" {
  bucket = "main-${var.MAIN_BUCKET_NAME}" # "heungbot-cdn-origin-bucket"
  tags   = var.FRONTEND_TAG
}

resource "aws_s3_bucket_public_access_block" "main_public_access" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
