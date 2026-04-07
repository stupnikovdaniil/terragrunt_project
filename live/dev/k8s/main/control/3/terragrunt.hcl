terraform {
  source = "${regex("^(.*)/live/.+", get_terragrunt_dir())[0]}/modules/vm"
}

include {
  path = find_in_parent_folders("common.hcl")
  expose =true
}

