terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0, < 7.0.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9.0, < 3.0.0"
    }

    http = {
      source  = "hashicorp/http"
      version = ">= 3.0.0"
    }
  }
}

#  AWS provider defined here
provider "aws" {
  region = var.region
}
