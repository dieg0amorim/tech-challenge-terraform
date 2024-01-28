terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
  required_version = ">= 1.1.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "example_bucket" {
  bucket = "my-unique-bucket-nameds4ahudasaa2385dg"  # Substitua pelo nome desejado
}

resource "aws_s3_bucket" "example_bucket-2" {
  bucket = "my-unique-bucket-nameds4tttahudsahudsaa2385dg-2"  # Substitua pelo nome desejado
}