output "MAIN_BUCKET_REGIONAL_DOMAIN_NAME" {
    value = aws_s3_bucket.main.bucket_regional_domain_name
}

output "MAIN_BUCKET_NAME" {
    value = aws_s3_bucket.main.bucket
}

output "MAIN_BUCKET_ARN" {
    value = aws_s3_bucket.main.arn
}

output "MAIN_BUCKET_ID" {
  value = aws_s3_bucket.main.id
}
