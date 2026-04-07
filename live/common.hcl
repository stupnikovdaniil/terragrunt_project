locals {
  vault_marker_path = find_in_parent_folders("vault-path.marker", "")
  vault_marker_dir  = dirname(local.vault_marker_path)
  full_path = abspath(get_terragrunt_dir())
  marker_path = local.vault_marker_dir != "." ? local.vault_marker_dir : local.full_path
  match     = regex("(^.*)/live/([^/]+)/(.*)", local.marker_path)

  root_prefix = local.match[0]
  env         = local.match[1]
  short_marker_path = local.match[2]

  vm_secrets_dir_segments         = split("/", local.short_marker_path)
  vm_secrets_dir                  = join("-", local.vm_secrets_dir_segments)
  vm_path_relative                = replace(local.full_path, "${local.root_prefix}/live/${local.env}/", "")
  vm_name                         = join("-", compact(split("/", local.vm_path_relative)))

  vault_path = "vm/${local.env}/${local.vm_secrets_dir}"
  local_vm_config_file = "${get_terragrunt_dir()}/vm-config.yaml"
  vm_config_file       = (
    fileexists(local.local_vm_config_file) ? local.local_vm_config_file : find_in_parent_folders("vm-config.yaml")
  )
}





remote_state {
  backend = "local"
  config = {
    path = "${local.root_prefix}/live/${local.env}/states/${local.vm_name}.tfstate"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc8"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.0.0"
    }
  }
}

provider "proxmox" {
  pm_api_url      = data.vault_kv_secret_v2.proxmox.data["api_url"]
  pm_user         = data.vault_kv_secret_v2.proxmox.data["username"]
  pm_password     = data.vault_kv_secret_v2.proxmox.data["password"]
  pm_tls_insecure = true
}

provider "vault" {
  address = "http://127.0.0.1:18200"
  token   = var.vault_token
}
EOF
}

inputs = {
  vault_token = get_env("VAULT_TOKEN", "")
  env             = local.env
  vm_name         = local.vm_name
  vault_path      = local.vault_path
  vm_config_file  = local.vm_config_file
}
