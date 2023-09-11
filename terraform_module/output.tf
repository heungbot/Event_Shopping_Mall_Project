output "ECR_REPOSITORY_URL" {
  value = module.heungbot-ecr.ECR_REPOSITORY_URL
}

output "MAIN_BUCKET_NAME" {
  value = module.heungbot-frontend-s3.MAIN_BUCKET_NAME
}

output "DISTRIBUTION_ID" {
  value = module.heungbot-frontend-cloudfront.MAIN_DISTRIBUTION_ID
}