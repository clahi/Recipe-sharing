terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.5"
    }
  }
  required_version = ">= 1.7"
}

provider "aws" {
  region = "us-east-1"
}

module "s3" {
  source = "../../global/s3"
  bucket_name = "recipe-sharing-asdf23"
}

module "cloudfront" {
  source = "../../global/cloudfront"
  bucket_domain_name = module.s3.bucket_domain_name
}