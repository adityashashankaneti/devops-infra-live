include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/modules//alb"
}

locals {
  config = yamldecode(file("resources.yaml"))
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_ids = {}
  }
}

dependency "subnet" {
  config_path = "../subnet"
  mock_outputs = {
    subnet_ids = {}
  }
}

dependency "security-group" {
  config_path = "../security-group"
  mock_outputs = {
    security_group_ids = {}
  }
}

inputs = {
  resources          = local.config
  project            = local.config.project
  vpc_ids            = dependency.vpc.outputs.vpc_ids
  subnet_ids         = dependency.subnet.outputs.subnet_ids
  security_group_ids = dependency.security-group.outputs.security_group_ids
}
