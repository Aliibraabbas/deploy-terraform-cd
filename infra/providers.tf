terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-backend-terraformbackends3bucket-jxpmap7i3ldb"
    key            = "infra/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-backend-TerraformBackendDynamoDBTable-1MWDTO5LZO1U9"
  }
}

provider "aws" {
  region = "eu-west-1"
}

