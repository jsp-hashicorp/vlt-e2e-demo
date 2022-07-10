data "consul_service_health" "target_srv" {
  name = "channel"
  passing = true
}

# Target 정보를 저정하는 
# Consul k/v를 hosts/팀/업무명/ip로 변경하자.
#❯ consul kv put hosts/channel/ip/n1 192.168.56.11
#Success! Data written to: hosts/channel/ip/n1
#❯ consul kv put hosts/channel/ip/n2 192.168.56.21
#Success! Data written to: hosts/channel/ip/n2

data "consul_key_prefix" "srv_list" {
  # Prefix to add to prepend to all of the subkey names below.
  path_prefix = "hosts/channel/ip/"
}


# Target Host 상의 정보와 Healthy Node 상의 정보가 동일한 경우
# local.health_info = true로 설정
# health_info가 true인 경우, code 실행 그렇지 않은 경우,,,

output "healthy_nodes" {
# # This is the value of the healthy node name
# IP 주소
  #value =data.consul_service_health.target_srv.results.*.node.0.address
  value =[for ip in data.consul_service_health.target_srv.results.*.node.0.address: ip]
}

output "target_nodes" {
  value = data.consul_key_prefix.srv_list.subkeys
}
/*
Outputs:
healthy_nodes = tolist([
  "n1",
  "n2",
])
*/