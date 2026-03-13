include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/modules//subnet"
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

inputs = {
  resources = local.config
  project   = local.config.project
  vpc_ids   = dependency.vpc.outputs.vpc_ids
}
