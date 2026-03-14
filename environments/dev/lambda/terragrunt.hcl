include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/modules//lambda"
}

locals {
  config        = yamldecode(file("resources.yaml"))
  project_vars  = yamldecode(file(find_in_parent_folders("project.yaml")))
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
  project            = local.project_vars.project
  subnet_ids         = dependency.subnet.outputs.subnet_ids
  security_group_ids = dependency.security-group.outputs.security_group_ids
}
