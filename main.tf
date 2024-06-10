resource "aws_ecr_repository" "my_new_repo" {
  name = "my-new-repo"          # Name of the repository
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_cluster" "ecs" {
  name = "cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "def" {
  family = "service"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = aws_iam_role.iam-role.arn
  network_mode = "awsvpc"
  cpu = 1024
  memory = 2048
  container_definitions = jsonencode([
    {
      name      = "nodejscontainer"
      image     = "211125303954.dkr.ecr.us-east-1.amazonaws.com/my-new-repo:latest"
      cpu       = 1024
      memory    = 2048
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
    },
  ])
}

resource "aws_ecs_service" "demo" {
  name            = "ecsservice"
  launch_type = "FARGATE"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.def.arn
  desired_count   = 2  

network_configuration {
    subnets          = data.aws_subnets.default.ids
    assign_public_ip = true
    security_groups = [aws_security_group.SG.id]
  }
}

data "aws_ecs_task_definition" "def" {
    task_definition = aws_ecs_task_definition.def.family
}
# Fetch the default VPC
data "aws_vpc" "default" {
  default = true
}
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


