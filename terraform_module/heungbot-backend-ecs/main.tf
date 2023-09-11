# ECS Cluster
# task in service
# task : image, cpu, memory... like docker run command. can include just one container or multiple container
# service : manage task's lifecycle -> decide number of task in cluster and manage ELB


# => 우리는 최소 2개의 task 필요함(frontend, backend)
# 근데 frontend service & backend service 어떻게 연결할 것인가??
# internal ALB 만드는 것도 방법이긴 한데, route53의 namespace를 사용하는 것도 하나의 방법
# ECS의 namespace를 사용하는 것이 비용적으로 이득일듯.

### Execution ROLE ###
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${var.APP_NAME}-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
    Name        = "${var.APP_NAME}-iam-role"
    Environment = var.APP_ENV
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

### ECS TASK Role ###



### ECS CLUSTER ###

resource "aws_ecs_cluster" "aws-ecs-cluster" {
  name = "${var.APP_NAME}-${var.APP_ENV}-cluster"
  tags = {
    Name        = "${var.APP_NAME}-ecs-cluster"
    Environment = var.APP_ENV
  }
}

# ASG
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.aws-ecs-cluster.name}/${aws_ecs_service.ecs-backend-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "${var.APP_NAME}-${var.APP_ENV}-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = 70
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "${var.APP_NAME}-${var.APP_ENV}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 70
  }
}

# backend Cloudwatch
resource "aws_cloudwatch_log_group" "backend-log-group" {
  name = "${var.APP_NAME}-${var.APP_ENV}-${var.SIDE[1]}-logs"

  tags = {
    Side        = var.SIDE[1]
    Application = var.APP_NAME
    Environment = var.APP_ENV
  }
}

# ecs task and service
# data "template_file" "ecs-backend-env-vars" {
#   template = file("./env/ecs_backend_env_vars.json")
# }

# backend task definition
resource "aws_ecs_task_definition" "ecs-backend-task-def" {
  family = "${var.APP_NAME}-${var.SIDE[1]}-task"
  container_definitions = jsonencode([
    {
      name       = "${var.APP_NAME}-${var.SIDE[1]}-${var.APP_ENV}-container"
      image      = "${var.ECR_REPOSITORY_URL}:${var.BACKEND_IMAGE}_${var.BUILD_NUMBER}"
      entryPoint = []
      essential  = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "${aws_cloudwatch_log_group.backend-log-group.id}"
          "awslogs-region"        = "${var.AWS_REGION}"
          "awslogs-stream-prefix" = "${var.APP_NAME}-${var.SIDE[1]}-${var.APP_ENV}"
        }
      }
      command = ["node", "app.js"]
      environment = [
        {
          name = "heungbot-test"
          value = "heungbot"
        }
      ]
      runtimePlatform = {
         operatingSystemFamily = "LINUX"
     }
    
      portMappings = [
        {
          containerPort = "${var.BACKEND_CONTAINER_PORT}"
          hostPort      = "${var.BACKEND_HOST_PORT}"
        }
      ]
      cpu         = 256
      memory      = 512
      networkMode = "awsvpc"
    }
  ])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn # EC2 instance에게 부여되는 role. fargate mode일 경우, container를 직접 실행하므로 "fargate task"를 실행하는 데 사용됨
  # execution role = task 자체 실행 권한


  task_role_arn = var.TASK_ROLE_ARN # task에서 실행되는 container에게 부여되는 role. e.g.) access s3 bucket
  # task role = task가 다른 aws service에 접근할 수 있도록 주는 권한

  

  tags = {
    Side        = var.SIDE[1]
    Name        = "${var.APP_NAME}-${var.SIDE[1]}-ecs-td"
    Environment = var.APP_ENV
  }
}

# ecs service
resource "aws_ecs_service" "ecs-backend-service" {
  name                 = "${var.APP_NAME}-${var.SIDE[1]}-${var.APP_ENV}-ecs-service"
  cluster              = aws_ecs_cluster.aws-ecs-cluster.id
  task_definition      = aws_ecs_task_definition.ecs-backend-task-def.arn
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = var.PRIVATE_SUBNET_IDS # input variable 설정
    assign_public_ip = false
    security_groups  = [var.BACKEND_ECS_SERVICE_SG_ID] # 마찬가지.
  }

  load_balancer {
    target_group_arn = var.MAIN_TARGET_GROUP_ARN
    container_name = "${var.APP_NAME}-${var.SIDE[1]}-${var.APP_ENV}-container"
    container_port   = var.BACKEND_CONTAINER_PORT
  }
}
# ECS Volume 필요한가? - 필요하다면 EFS 사용하자.


