# outputs.tf
output "vm_name" {
  value = local.config.vm_name
}

output "vault_user" {
  value = nonsensitive(local.vault["cloudinit_user"])
}
output "vault_pass" {
  value = nonsensitive(local.vault["cloudinit_password"])
}
output "vault_key" {
  value = nonsensitive(local.vault["ssh_public_key"])
}
output "vm_ip" {
  value = proxmox_vm_qemu.vm.default_ipv4_address
}

output "vault_path" {
  value = var.vault_path
}
