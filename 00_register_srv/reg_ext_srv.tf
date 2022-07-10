# Using the pre-insterted host info
# retreive all the keys 
data "consul_key_prefix" "srv_list" {
  # Prefix to add to prepend to all of the subkey names below.
  path_prefix = "hosts/channel/ip/"
}

locals {
  target_num      = length(data.consul_key_prefix.srv_list.subkeys)
  target_hostname = keys(data.consul_key_prefix.srv_list.subkeys)
  target_ip       = values(data.consul_key_prefix.srv_list.subkeys)
}

# Register external node
resource "consul_node" "srv_target" {
  count = local.target_num
  name    = element(local.target_hostname,count.index)
  address = element(local.target_ip,count.index)

  meta = {
    "external-node"  = "true",
    "external-probe" = "true",
    "app" = "channel"
  }
}


## Register external service 
resource "consul_service" "srv_ssh" {

  count = local.target_num
  name    = "channel"
  #name    = "counting-service"
  node    = element(local.target_hostname,count.index)
  port    = 22
  tags = ["channel-${count.index}"]

   meta = {
    "app" = "channel"
  }


  check {
    check_id = "ssh"
    name                              = "Target Host SSH health check"
    status                             = "passing"
    tcp                             = "${element(local.target_ip,count.index)}:22"
   # tls_skip_verify                    = true
    interval                          = "5s"
    timeout                           = "3s"
    deregister_critical_service_after = "10s"
  }
  depends_on = [consul_node.srv_target]
}
