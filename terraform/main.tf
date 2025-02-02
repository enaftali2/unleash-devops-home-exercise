provider "aws" {
  region = var.region
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
  availability_zone = element(["${var.region}a", "${var.region}b"], count.index)
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

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "home-exercise-eks"
  cluster_version = "1.27"
  vpc_id          = aws_vpc.app_vpc.id
  subnet_ids      = aws_subnet.public_subnets[*].id
}
