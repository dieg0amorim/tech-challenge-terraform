data "aws_secretsmanager_secret" "db_credentials" {
  name = "secret.ecs"
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
  vpc_security_group_ids = ["sg-08c50fced7a49f795"]

}

