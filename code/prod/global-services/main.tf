terraform {
  required_providers {
    aws = {
<<<<<<< HEAD
      source  = "hashicorp/aws"
      version = "~> 4.5"
=======
        source = "hashicorp/aws"
        version = "~> 4.5"
>>>>>>> 237e49aa6fecda982217174204c4ce4f36d57cbb
    }
  }
  required_version = ">= 1.7"
}

provider "aws" {
  region = "us-east-1"
}

module "s3" {
<<<<<<< HEAD
  source      = "../../global/s3"
=======
  source = "../../global/s3"
>>>>>>> 237e49aa6fecda982217174204c4ce4f36d57cbb
  bucket_name = "recipe-sharing-asdf23"
}

module "cloudfront" {
<<<<<<< HEAD
  source             = "../../global/cloudfront"
=======
  source = "../../global/cloudfront"
>>>>>>> 237e49aa6fecda982217174204c4ce4f36d57cbb
  bucket_domain_name = module.s3.bucket_domain_name
}