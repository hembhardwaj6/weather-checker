terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.90.0"
    }
  }

  # # S3 backend can be used to store terraform state
  # backend "s3" {
  #   bucket         = "s3-tfstate"
  #   use_lockfile   = "true"
  #   key            = "aws/weather-checker"
  # }
}

provider "aws" {
  alias = "frakfurt"
  region = "eu-central-1"
  default_tags {
    tags = {
      Terraform   = "true"
      Application = var.application
      Name        = var.instance_name
    }
  }
}

provider "aws" {
  alias = "us-west"
  region = "us-west-1"
  default_tags {
    tags = {
      Terraform   = "true"
      Application = var.application
      Name        = var.instance_name
    }
  }
}
