terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.5"
    }
  }
  required_version = ">= 1.7"
}

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../../modules/vpc"
}

module "application_load_balancer" {
  source     = "../../modules/load-balancer"
  subnet_ids = [module.vpc.private_subnetA, module.vpc.private_subnetB]
  alb_name   = "application-load-balancer"
  vpc_id     = module.vpc.vpc_id
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

module "auto_scaling_group" {
  source        = "../../modules/cluster"
  cluster_name  = "web-cluster"
  vpc_id        = module.vpc.vpc_id
  instance_type = "t2.micro"
  min_size      = 2
  max_size      = 2
  ami           = data.aws_ami.amazon_linux.id
  subnet_ids    = [module.vpc.private_subnetA, module.vpc.private_subnetB]

  user_data = base64encode(templatefile("${path.module}/user_data/user_data.sh", {}))
}