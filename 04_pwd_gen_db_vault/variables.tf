variable "consul_addr" {
  description = "Consul Server Address ip_addr:8500"
}

variable "consul_dc" {
  description = "Consul DC"
}

#variable "vault_addr" {
#  description = "Vault Server Address : IP_ADDR:8200"
#}

variable "hcv_user" {
  description = "HashiCorp Vault OS Account"
}

variable "hcv_passwd" {
  description = "HashiCorp Vault OS Account Password"
}

variable "enc_srv" {
  description = "Server IP for Encryption"
}

# Target DB Account List 
# Need to be chnaged whenever DB Account is added or removed.
variable "db_ids" {
  description = "Target DB Accounts list"
  type        = list(string)
  default     = ["uidbs01h", "uidbs02h", "uidbs03h"]
}