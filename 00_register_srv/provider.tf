# Specify the Consul provider source and version
terraform {
  required_providers {
    consul = {
      source = "hashicorp/consul"
      version = "2.11.0"
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
