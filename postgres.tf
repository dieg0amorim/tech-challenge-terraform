# Use a VPC e subnet pública existentes
data "aws_vpc" "vpc" {
  id = aws_vpc.vpc.id
}

/*
data "aws_subnet" "public_subnet" {
  vpc_id = data.aws_vpc.vpc.id
}
*/

data "aws_subnet" "public_subnet" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.vpc.id]
  }
  filter {
    name   = "cidr-block"
    values = ["192.168.100.0/24"]
  }
}

data "aws_security_group" "security_group" {
  id = aws_security_group.security_group.id
}

data "aws_secretsmanager_secret" "db_credentials" {
  name = "secrets.ecs"
}

data "aws_secretsmanager_secret_version" "latest" {
  secret_id = data.aws_secretsmanager_secret.db_credentials.id
}

locals {
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.latest.secret_string)
}


resource "aws_db_instance" "rds" {
  identifier           = "postgresdb"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "15.3"
  instance_class       = "db.t3.micro"
  username             = local.db_credentials.username
  password             = local.db_credentials.password 
  storage_encrypted    = true
  

  skip_final_snapshot = true

  # Configuração de segurança
  vpc_security_group_ids = [aws_security_group.security_group.id]
  db_subnet_group_name = aws_db_subnet_group.example.name
  

}

