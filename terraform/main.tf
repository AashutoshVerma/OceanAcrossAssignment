// Root provider configuration and minimal backend guidance
terraform {
  required_version = ">= 1.2"
  required_providers {
    aws = { source = "hashicorp/aws" version = ">= 4.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

// This root file is intentionally light — environments should wrap modules.
