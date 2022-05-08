resource "aws_ecs_task_definition" "test-task-def" {
  family = "hello-world-app"
  network_mode = "awsvpc"
  requires_compatibilities = [ "FARGATE" ]
  cpu = 1024
  memory = 2048
  container_definitions = <<DEFINITION
  [
      {
          "image": "dijamonthabeatz/simple-flask-app",
          "cpu": 1024,
          "memory": 2048,
          "name": "simple-flask-app",
          "networkMode": "awsvpc",
          "portMappings": [
              {
                  "containerPort": 5000,
                  "hostPort": 5000

              }
          ]
      }
  ]
  DEFINITION
}

resource "aws_ecs_cluster" "test-cluster" {
  name = "example-cluster"
}

resource "aws_ecs_service" "ecs-service" {
    name = "hello-world-service"
    cluster = aws_ecs_cluster.test-cluster.id
    task_definition = aws_ecs_task_definition.test-task-def.id
    desired_count = 2
    launch_type = "FARGATE"
    network_configuration {
      security_groups = var.ecs_sg 
      subnets = var.public_subnet 
      assign_public_ip = true
    }
    load_balancer {
      target_group_arn = var.tg_arn 
      container_name = "simple-flask-app"
      container_port = 5000
    }

    depends_on = [
      var.lb
    ]
}