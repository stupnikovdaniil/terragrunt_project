# modules/vm/variables.tf
# Variable definitions and validations for the VM module

variable "ipconfig0" {
  type    = string
  default = null
}

variable "env" {
  type        = string
  description = "Environment identifier: dev, staging, prod."
  validation {
    condition     = length(var.env) > 0
    error_message = "❌ The 'env' variable must not be empty."
  }
}

variable "vm_name" {
  type        = string
  description = "Unique VM name derived from the Terragrunt path."
  validation {
    condition     = length(var.vm_name) > 0
    error_message = "❌ The 'vm_name' variable must not be empty."
  }
}

variable "vm_config_file" {
  type        = string
  description = "Path to the vm-config.yaml file."
  validation {
    condition     = fileexists(var.vm_config_file)
    error_message = "❌ The specified vm_config_file '${var.vm_config_file}' does not exist."
  }
}

variable "vault_token" {
  description = "Vault token to authenticate against Vault server"
  type        = string
}


variable "vault_path" {
  type        = string
  description = "Vault path for VM secrets, e.g. 'vm/dev/jenkins-1'. Ignored if use_vault=false."
}
