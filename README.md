# modules/vm/README.md

# Module `vm`

This module creates a QEMU VM in Proxmox and retrieves VM secrets from Vault or a YAML file.

## Variables

| Name              | Type    | Description                                                                                   |
|-------------------|---------|-----------------------------------------------------------------------------------------------|
| `env`             | string  | Environment identifier: `dev`, `staging`, `prod`.                                             |
| `vm_name`         | string  | Unique VM name derived from the Terragrunt path.                                              |
| `vm_config_file`  | string  | Path to the `vm-config.yaml` file (must exist).                                               |
| `use_vault`       | bool    | `true` = read secrets from Vault; `false` = read `ssh_public_key` and `cloudinit_*` from YAML. |
| `vault_path`      | string  | Vault path for VM secrets (ignored if `use_vault = false`).                                   |

## vm-config.yaml format

```yaml
# Required fields:
template_name: ubuntu-22-template
target_node: proxmox-node1
vm_cores: 2
vm_memory: 4096

# Optional:
use_vault: true                      # or false
vault_path: "vm/dev/jenkins-1"       # if different from vm/${env}/${vm_name}

# If use_vault: false, the following are required:
ssh_public_key: "ssh-rsa AAAA…"
cloudinit_user: "ubuntu"
cloudinit_password: "s3cr3t"
