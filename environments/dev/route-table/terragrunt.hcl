include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/modules//route-table"
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

dependency "internet-gateway" {
  config_path = "../internet-gateway"
  mock_outputs = {
    igw_ids = {}
  }
}

dependency "nat-gateway" {
  config_path = "../nat-gateway"
  mock_outputs = {
    nat_gateway_ids = {}
  }
}

inputs = {
  resources       = local.config
  project         = local.config.project
  vpc_ids         = dependency.vpc.outputs.vpc_ids
  subnet_ids      = dependency.subnet.outputs.subnet_ids
  igw_ids         = dependency.internet-gateway.outputs.igw_ids
  nat_gateway_ids = dependency.nat-gateway.outputs.nat_gateway_ids
}
