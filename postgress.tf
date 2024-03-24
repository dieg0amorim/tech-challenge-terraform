resource "aws_ecs_task_definition" "banco_postgress" {
  family                   = "my-task-banco-postgress"
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
    "image": "postgress:latest",
    "portMappings": [
      {
        "containerPort": 5432,
        "hostPort": 5432
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "hackathon-log-group",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "hackathon"
      }
    }
  }
]  
EOF
}

resource "aws_ecs_service" "postgress_service" {
  name            = "postgress-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.banco_postgress.arn
  launch_type     = "FARGATE"
#  desired_count = 1

  network_configuration {
    subnets = [aws_subnet.public_subnet.id]
    security_groups = [aws_security_group.security_group.id]
    assign_public_ip = true
   
  }
}
