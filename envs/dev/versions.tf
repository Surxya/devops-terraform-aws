terraform {
  required_version = ">= 1.11.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "surya-tfstate-5831047"
    key          = "dev/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }
}
provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project   = "devops-terraform-aws"
      Env       = "dev"
      ManagedBy = "terraform"
      Owner     = "surya"
    }
  }
}
