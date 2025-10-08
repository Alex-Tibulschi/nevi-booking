locals { name_prefix = "${var.project}-api-solo" }

# Logs for the task
resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/${local.name_prefix}"
  retention_in_days = 7
}

# IAM task execution role (pull ECR + write logs)
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { 
        type = "Service"
        identifiers = ["ecs-tasks.amazonaws.com"] 
    }
  }
}
resource "aws_iam_role" "task_execution" {
  name               = "${local.name_prefix}-exec"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}
resource "aws_iam_role_policy_attachment" "exec_ecr" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_role_policy_attachment" "exec_logs" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# Security group for the task: allow internet to container_port
resource "aws_security_group" "task" {
  name        = "${local.name_prefix}-sg"
  description = "Allow inbound to container from internet; egress all"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP to container"
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = "${local.name_prefix}-cluster"
}

# Task definition (Fargate)
resource "aws_ecs_task_definition" "api" {
  family                   = "${local.name_prefix}-td"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.cpu)
  memory                   = tostring(var.memory)
  execution_role_arn       = aws_iam_role.task_execution.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = "api"
      image     = var.ecr_image
      essential = true
      portMappings = [{
        containerPort = var.container_port
        hostPort      = var.container_port
        protocol      = "tcp"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.api.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "api"
        }
      }

    }
  ])
}

# ECS Service (assigns a public IP so it can be reached without NAT/LB)
resource "aws_ecs_service" "api" {
  name            = "${local.name_prefix}-svc"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [aws_security_group.task.id]
    assign_public_ip = true
  }
}

output "task_security_group_id" { value = aws_security_group.task.id }
output "cluster_name"           { value = aws_ecs_cluster.this.name }
output "service_name"           { value = aws_ecs_service.api.name }
