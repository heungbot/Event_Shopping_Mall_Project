output "MAIN_DISTRIBUTION_ID" {
  value = aws_cloudfront_distribution.main_s3_distribution.id
}

output "MAIN_DISTRIBUTION_ARN" {
  value = aws_cloudfront_distribution.main_s3_distribution.arn
}