provider "aws" {
  region = var.region
}
terraform {
  required_providers {
    aws = {
      version = "~> 5.61.0"
    }
  }
  required_version = "~> 1.7.2"
}