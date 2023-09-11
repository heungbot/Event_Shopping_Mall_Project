output "ALB_SG_ID" {
    value = aws_security_group.main-alb-sg.id
}

output "BASTION_SG_ID" {
    value = aws_security_group.bastion-sg.id
}

output "ECS_SERVICE_SG_ID" {
    value = aws_security_group.backend-ecs-service-sg.id
}

output "CACHE_SG_ID" {
    value = aws_security_group.main-alb-sg.id
}

output "RDS_SG_ID" {
    value = aws_security_group.rds-sg.id
}