# Specify the Consul provider source and version
terraform {
  required_providers {
    consul = {
      source  = "hashicorp/consul"
      version = "2.11.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.2.1"
    }
  }
}

# Configure the Consul provider
provider "consul" {
  address    = var.consul_addr
  datacenter = var.consul_dc

  # SecretID from the previous step
  #token      = "91f5e30c-c51b-8399-39bb-a902346205c4"
}

provider "vault" {
  # It is strongly recommended to configure this provider through the
  # environment variables described above, so that each user can have
  # separate credentials set in the environment.
  #
  # This will default to using $VAULT_ADDR
  # But can be set explicitly
  # address = "https://vault.example.net:8200"
  address = var.vault_addr
}
