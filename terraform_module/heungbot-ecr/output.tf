output "ECR_REPOSITORY_URL" {
    value = data.aws_ecr_repository.heungbot-ecr.repository_url
}

output "ECR_REGISTRY_ID" {
    value = data.aws_ecr_repository.heungbot-ecr.registry_id
}