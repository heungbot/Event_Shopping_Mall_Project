data "aws_ecr_repository" "heungbot-ecr" {
  name = var.ECR_REPOSITORY_NAME
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = data.aws_ecr_repository.heungbot-ecr.name
 
  policy = jsonencode({
   rules = [{
     rulePriority = 1
     description  = "keep 10 images in ecr repo"
     action       = {
       type = "expire"
     }
     selection     = {
       tagStatus   = "any"
       countType   = "imageCountMoreThan"
       countNumber = 10
     }
   }]
  })
}