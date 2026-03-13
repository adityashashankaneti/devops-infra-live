include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/modules//nat-gateway"
}

locals {
  config = yamldecode(file("resources.yaml"))
}

dependency "subnet" {
  config_path = "../subnet"
  mock_outputs = {
    subnet_ids = {}
  }
}

inputs = {
  resources  = local.config
  project    = local.config.project
  subnet_ids = dependency.subnet.outputs.subnet_ids
}
