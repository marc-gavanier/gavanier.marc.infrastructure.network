terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "marc-gavanier"

    workspaces {
      prefix = "marc-gavanier-network-"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.11"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}
