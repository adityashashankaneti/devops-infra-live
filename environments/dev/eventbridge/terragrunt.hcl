include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/modules//eventbridge"
}

locals {
  config        = yamldecode(file("resources.yaml"))
  project_vars  = yamldecode(file(find_in_parent_folders("project.yaml")))
}

inputs = {
  resources = local.config
  project   = local.project_vars.project
}
