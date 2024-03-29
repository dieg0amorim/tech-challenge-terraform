resource "aws_ecs_task_definition" "my_task-redis" {
  family                   = "my-task-redis"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  cpu = "512"  # 2 vCPUs
  memory = "4096"  # 4GB de memória
  depends_on = [ aws_cloudwatch_log_group.example ]
  


  container_definitions = <<EOF
[
  {
    "name": "my-container",
    "image": "redis:latest",
    "portMappings": [
      {
        "containerPort": 6379,
        "hostPort": 6379
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "tech-challenge-log-group",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "redis-2"
      }
    }
  }
]  
EOF
}

resource "aws_ecs_service" "my_service_redis" {
  name            = "redis-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task-redis.arn
  launch_type     = "FARGATE"
#  desired_count = 1

  network_configuration {
    subnets = [aws_subnet.public_subnet.id]
    security_groups = [aws_security_group.security_group.id]
    assign_public_ip = true
   
  }
}