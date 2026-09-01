terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "petclinic-tfstate-s3-20588"
    key            = "petclinic/prod/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "petclinic-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "free-tier"
}