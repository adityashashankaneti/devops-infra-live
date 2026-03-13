include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/modules//vpc"
}

locals {
  config = yamldecode(file("resources.yaml"))
}

inputs = {
  resources = local.config
  project   = local.config.project
}
