terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket  = "carelink-shilpa-tfstate-255945442255-us-east-1"
    key     = "staging/github-oidc/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
