provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "my-app-tfstate"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "home-exercise-s3-bucket"
}

resource "aws_ecr_repository" "app_repo" {
  name = "home-exercise-repo"
}

resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnets" {
  count             = 2
  vpc_id           = aws_vpc.app_vpc.id
  cidr_block       = cidrsubnet(aws_vpc.app_vpc.cidr_block, 8, count.index)
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
}

resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.app_vpc.id

  ingress {
    from_port   = 80
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "github_runner_sg" {
  name        = "github_runner_sg"
  description = "Allow SSH and other necessary traffic"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["62.56.147.93/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "home-exercise-eks"
  cluster_version = "1.27"
  vpc_id          = aws_vpc.app_vpc.id
  subnet_ids      = aws_subnet.public_subnets[*].id

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
}
