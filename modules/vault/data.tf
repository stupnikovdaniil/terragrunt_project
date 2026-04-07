variable "env" {
  type = string
}

variable "vm_name" {
  type = string
}

data "vault_kv_secret_v2" "vm_config" {
  name = "secrets/vm/${var.env}/${var.vm_name}"
}

output "vm_config" {
  value = data.vault_kv_secret_v2.vm_config.data
}

