include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/modules//internet-gateway"
}

locals {
  config        = yamldecode(file("resources.yaml"))
  project_vars  = yamldecode(file(find_in_parent_folders("project.yaml")))
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_ids = {}
  }
}

inputs = {
  resources = local.config
  project   = local.project_vars.project
  vpc_ids   = dependency.vpc.outputs.vpc_ids
}
