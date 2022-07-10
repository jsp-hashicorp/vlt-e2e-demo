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
}
