terraform {
  source = "${regex("^(.*)/live/.+", get_terragrunt_dir())[0]}/modules/vm"
}

include {
  path = find_in_parent_folders("common.hcl")
  expose =true
}

inputs = {
  vault_path     = "vm/${include.inputs.env}/${include.inputs.vm_path}"
  vm_config_file = "${get_terragrunt_dir()}/vm-config.yaml"
}

