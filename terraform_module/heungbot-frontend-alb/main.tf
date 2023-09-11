## ALB ##
resource "aws_alb" "main-alb" {
  name               = "${var.APP_NAME}-${var.SIDE[1]}-${var.APP_ENV}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.PUBLIC_SUBNET_IDS# aws_subnet.public.*.id
  security_groups    = [var.ALB_SG_ID]

  tags = {
    Name        = "${var.APP_NAME}-${var.SIDE[1]}-alb"
    Environment = var.APP_ENV
  }
}

resource "aws_lb_target_group" "main-target-group" {
  name        = "${var.APP_NAME}-${var.SIDE[1]}-${var.APP_ENV}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip" # for fargate type
  vpc_id      = var.VPC_ID

  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.HEALTH_CHECK_PATH
    unhealthy_threshold = "2"
  }

  tags = {
    Name        = "${var.APP_NAME}-${var.SIDE[1]}-tg"
    Environment = var.APP_ENV
  }
}

resource "aws_lb_listener" "main-listener" {
  load_balancer_arn = aws_alb.main-alb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main-target-group.id
  }
}

resource "aws_lb_listener_rule" "ecs_fargate_listener_rule" {
  listener_arn = aws_lb_listener.main-listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main-target-group.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

resource "null_resource" "INTERNET-FACING-ALB-DOMAIN-TO-FRONTEND-DIRECTORY" {
  provisioner "local-exec" {
    # command = "echo \"ALB_DOMAIN=\${aws_alb.main-alb.dns_name}\" >> \${var.JENKINS_WORKSPACE_PATH}/frontend/.env"
    # 아래의 command = sudo 권한을 사용하기 때문에 terminal에서 비번 입력해 줘야함.
    # but jenkins 서버 설정에서는 sudo 권한 password 필요없음
    command = <<EOC
      echo "ALB_DOMAIN=$ALB_DNS_NAME" >> $JENKINS_WORKSPACE_PATH/frontend/.env
    EOC

    environment = {
      ALB_DNS_NAME           = aws_alb.main-alb.dns_name
      JENKINS_WORKSPACE_PATH = var.JENKINS_WORKSPACE_PATH
    }
  }
  depends_on = [aws_alb.main-alb]
}

