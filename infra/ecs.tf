resource "aws_ecs_cluster" "app_cluster" {
  name = "cloud-devops-cluster"
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "backend"
      image = "${var.dockerhub_username}/deploy-terraform-cd-server:${var.server_image_tag}"
      portMappings = [
        {
          containerPort = 3005
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/backend"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    },
    {
      name  = "frontend"
      image = "${var.dockerhub_username}/deploy-terraform-cd-client:${var.client_image_tag}"
      portMappings = [
        {
          containerPort = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/frontend"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "app_service" {
  name            = "cloud-devops-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "frontend"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.app_listener]
}

