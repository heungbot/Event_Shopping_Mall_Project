### BASTION SG
resource "aws_security_group" "bastion-sg" {
  name   = "main-bastion-sg"
  vpc_id = var.VPC_ID

  ingress {
    from_port   = var.BASTION_PORT
    protocol    = "tcp"
    to_port     = var.BASTION_PORT
    cidr_blocks = var.ADMIN_CIDR
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.APP_NAME}-bastion-sg"
    Environment = var.APP_ENV
  }
}

### ALB SG
// https://dev.to/kaspersfranz/limit-traffic-to-only-cloudfront-traffic-in-aws-alb-3c6 참고
data "aws_ec2_managed_prefix_list" "cloudfront-prefix-list" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group" "main-alb-sg" { # should allow only cloudfront request
  vpc_id = var.VPC_ID
  name   = "main-alb-sg"

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront-prefix-list.id]
  }

  # for test under line ingress 
  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.APP_NAME}-${var.SIDE[1]}-alb-sg"
    Environment = var.APP_ENV
  }
}


### ECS SERVIE SG
resource "aws_security_group" "backend-ecs-service-sg" {
  vpc_id = var.VPC_ID
  name   = "backend-ecs-service-sg"

  ingress {
    from_port       = var.ECS_SERVICE_PORT
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.main-alb-sg.id]
  }

  egress {
    from_port        = var.ECS_SERVICE_PORT
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.APP_NAME}-${var.SIDE[1]}-service-sg"
    Environment = var.APP_ENV
  }
}

### CACHE SG(memcached)
resource "aws_security_group" "cache-sg" {
  vpc_id = var.VPC_ID
  name   = "main-cache-sg"

  ingress {
    from_port = var.CACHE_PORT
    to_port   = var.CACHE_PORT
    protocol  = "tcp"
    security_groups = [
      aws_security_group.backend-ecs-service-sg.id
    ]
  }

    ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    security_groups = [
      aws_security_group.bastion-sg.id
    ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.APP_NAME}-cache-sg"
    Environment = var.APP_ENV
  }
}

### RDS SG(mysql)
resource "aws_security_group" "rds-sg" {
  vpc_id = var.VPC_ID
  name   = "main-aurora-mysql-sg"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    security_groups = [
      aws_security_group.bastion-sg.id
    ]
  }
  ingress {
    from_port = var.DB_PORT
    to_port   = var.DB_PORT
    protocol  = "tcp"
    security_groups = [
      aws_security_group.backend-ecs-service-sg.id,
    ]
  }

  ingress {
    from_port = var.CACHE_PORT
    to_port   = var.CACHE_PORT
    protocol  = "tcp"
    security_groups = [
      aws_security_group.cache-sg.id
    ]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.APP_NAME}-aurora-sg"
    Environment = var.APP_ENV
  }
}



