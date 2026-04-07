terraform {
  backend "local" {}
}

locals {
  vault        = data.vault_kv_secret_v2.vm.data
  config_raw   = yamldecode(file(var.vm_config_file))

  config = merge(
    local.config_raw,
    {
      vm_name = lookup(local.config_raw, "vm_name", var.vm_name)
    }
  )
}

data "vault_kv_secret_v2" "vm" {
  mount = "secrets"
  name  = var.vault_path
}




data "vault_kv_secret_v2" "proxmox" {
  name = "/vm/${var.env}/proxmox"
  mount = "secrets"
}

resource "proxmox_vm_qemu" "vm" {
  name        = local.config.vm_name
  target_node = local.config.target_node
  clone       = local.config.template_name
  os_type     = "cloud-init"
  
  cores  = local.config.vm_cores
  memory = local.config.vm_memory

  scsihw   = "virtio-scsi-single"
  bootdisk = "scsi0"

  serial {
    id    = 0
    type  = "socket"
  }

  vga {
    type = "serial0"
  }

  disk {
    slot    = "ide2"
    type    = "cloudinit"
    storage = lookup(local.config, "vm_disk_storage", "local-lvm")
  }

  disk {
    slot    = "scsi0"
    type    = "disk"
    storage = lookup(local.config, "vm_disk_storage", "local-lvm")
    size    = local.config.vm_disk_size
  }

  dynamic "disk" {
  for_each = {
    for d in lookup(local.config, "disks", []) :
    d.slot => d if d.slot != "scsi0"
  }

  content {
    slot    = disk.value.slot
    type    = "disk"
    storage = lookup(local.config, "vm_disk_storage", "local-lvm")
    size    = disk.value.size
  }
  }
  network {
    id     = 0
    model  = lookup(local.config, "vm_net_model", "virtio")
    bridge = lookup(local.config, "vm_net_bridge", "vmbr0")
  }
  
  ipconfig0 = coalesce(var.ipconfig0, "ip=dhcp")

  sshkeys    = local.vault["ssh_public_key"]
  ciuser     = local.vault["cloudinit_user"]
  cipassword = local.vault["cloudinit_password"]

  agent = 1
  tags  = lookup(local.config, "tags", null)

  lifecycle {
    ignore_changes = [network, sshkeys]
  }
}
