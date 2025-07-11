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

# Getting the vpc we are going to deploy to
data "aws_vpc" "main_vpc" {
  id = var.vpc_id
}

# Getting the subnets of the vpc
data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    Name = "public"
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    Name = "private"
  }
}


module "application_load_balancer" {
  source = "../../modules/load-balancer"
  # subnet_ids = [module.vpc.private_subnetA, module.vpc.private_subnetB]
  subnet_ids = data.aws_subnets.public_subnets.ids
  alb_name   = "application-load-balancer"
  # vpc_id     = module.vpc.vpc_id
  vpc_id = var.vpc_id
}

module "auto_scaling_group" {
  source       = "../../modules/cluster"
  cluster_name = "web-cluster"
  # vpc_id        = module.vpc.vpc_id
  vpc_id        = var.vpc_id
  instance_type = "t2.micro"
  min_size      = 2
  max_size      = 2
  # ami           = data.aws_ami.amazon_linux.id
  ami = "ami-020cba7c55df1f615"
  # subnet_ids    = [module.vpc.private_subnetA, module.vpc.private_subnetB]
  subnet_ids = data.aws_subnets.private_subnets.ids

  target_group_arns = [module.application_load_balancer.alb_target_group]
  health_check_type = "ELB"

  dynamo_arn = module.dynomoDB.dynamo_arn
  user_data  = base64encode(templatefile("${path.module}/user_data/user_data.sh", {GitRepoURL="https://github.com/PacktPublishing/AWS-Cloud-Projects.git"}))
}

module "dynomoDB" {
  source = "../../modules/data-stores/dynamoDB"

}