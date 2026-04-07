#cloud-config
hostname: ${vm_name}
manage_etc_hosts: true

users:
  - name: ${vault_user}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    shell: /bin/bash
    ssh-authorized-keys:
      - "${vault_key}"

chpasswd:
  list: |
    ${vault_user}:${vault_pass}
  expire: false

