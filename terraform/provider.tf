terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      version = ">= 4.0.0"
      source  = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket  = "tf-state-replication-source-350726165848"
    key     = "terraform-dynamo-db.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = "development"
      Project     = "aws-dynamo-db"
      ManagedBy   = "Terraform"
      Repository  = "aws-dynamo-db"
      Owner       = "ryan_davis542@outlook.com"
      CostCenter  = "Personal"
      Region      = var.region
    }
  }
}
