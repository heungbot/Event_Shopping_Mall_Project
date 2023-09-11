output "main_target_group_arn" {
  value = aws_lb_target_group.main-target-group.arn
}

output "ALB_ARN" {
  value = aws_alb.main-alb.arn
}

output "ALB_DNS_NAME" {
  value = aws_alb.main-alb.dns_name
}