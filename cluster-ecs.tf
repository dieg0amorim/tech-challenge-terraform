resource "aws_ecs_cluster" "my_cluster" {
  name = "cluster-techchallenge"
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecs_execution_policy" {
  name = "ecs_execution_policy"

  description = "Policy for ECS task execution role"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:GetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "secretsmanager:GetSecretValue"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "ecs_execution_policy_attachment" {
  policy_arn = aws_iam_policy.ecs_execution_policy.arn
  role       = aws_iam_role.ecs_execution_role.name
}

resource "aws_ecs_task_definition" "my_task" {
  family                   = "my-task-app"
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
    "image": "pedrovcorsino/tech_challenge:latest",
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "techchallenge-log-group",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "tech-challenge"
      }
    },     
    "secrets": [
      {
        "valueFrom": "arn:aws:secretsmanager:us-east-1:961820325724:secret:secret.ecs-tTFcf3",
        "name": "secret.ecs"
      }
    ]
  }
]  
EOF
}

resource "aws_ecs_service" "my_service" {
  name            = "techchallenge-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  launch_type     = "FARGATE"
#  desired_count = 1

  network_configuration {
    subnets = ["subnet-05726759a2fb03543"]
    security_groups = ["sg-08c50fced7a49f795"]
    assign_public_ip = true
    
  }
}
