# Crie uma VPC
resource "aws_vpc" "vpc" {
  cidr_block = "192.168.0.0/16"
}

# Crie um Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

# Crie uma subnet pública
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.100.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "example_public2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.200.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "security_group" {
  name        = "sg para bd e ecs"
  description = "Security Group para liberacao de portas do ecs e bancos de dados"

  # Regras de entrada
  ingress {
    from_port   = 15672
    to_port     = 15672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Isso permite o acesso de qualquer endereço
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Isso permite o acesso de qualquer endereço
  }

  ingress {
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Isso permite o acesso de qualquer endereço
  }

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Isso permite o acesso de qualquer endereço
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Isso permite o acesso de qualquer endereço
  }

  # Regra de saída para acesso à Internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Isso permite todo o tráfego
    cidr_blocks = ["0.0.0.0/0"] # Isso permite o acesso à Internet
  }

  vpc_id = aws_vpc.vpc.id
}



resource "aws_db_subnet_group" "example" {
  name        = "meudbsubnetgroup" # Nome em letras minúsculas
  subnet_ids  = [aws_subnet.public_subnet.id,aws_subnet.example_public2.id]
  description = "DB Subnet Group para meu banco"
}