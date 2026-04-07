terraform {
  source = "${regex("^(.*)/live/.+", get_terragrunt_dir())[0]}/modules/vm"
}

include {
  path   = find_in_parent_folders("common.hcl")
  expose = true
}

inputs = {
  ipconfig0 = "ip=192.168.1.105/24,gw=192.168.1.1"
}
