# Root Terragrunt configuration
# Each project gets its own directory under environments/<project>/
# Resource-type subdirectories inherit this config via include "root"

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "${local.project}-tf-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    dynamodb_table = "${local.project}-tf-lock"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      required_version = ">= 1.5"
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "~> 5.0"
        }
      }
    }

    provider "aws" {
      region = "${local.region}"

      default_tags {
        tags = {
          Project   = "${local.project}"
          ManagedBy = "terraform"
        }
      }
    }
  EOF
}

locals {
  # Read project-level config
  project_config = yamldecode(file("project.yaml"))
  project        = local.project_config.project
  region         = local.project_config.region
}
