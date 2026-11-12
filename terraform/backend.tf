terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote State di S3 dengan Enkripsi KMS & State Locking di DynamoDB (Wajib Lab 2)
  backend "s3" {
    bucket         = "fasilkomti-usu-devops-tfstate-bucket"
    key            = "prod/ecs-fargate-cicd/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "fasilkomti-usu-devops-tfstate-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  # Best Practice FinOps (Slide 11): Cost Tagging wajib pada semua resource
  default_tags {
    tags = {
      Project   = var.project_name
      Env       = var.environment
      Owner     = var.owner
      ManagedBy = "Terraform"
    }
  }
}
