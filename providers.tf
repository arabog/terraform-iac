terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #   version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider: Shared Configuration and Credentials Files
provider "aws" {
  region = "us-east-1"
  #   shared_config_files      = ["/Users/tf_user/.aws/conf"]
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "terraform"
}