# File Name : pwd_gen.tf
# Purpose : Rotate the DB password and encrypt, push it to Consul KV
# Followings are the overall process
# 1. DB 시크릇 엔진 기반 Password 변경
# 2 Consul KV에 저장

# 3. 저장된 KV 암호화 (SSH) -->
# 4. 암호화된 PWD를 Consul KV에 저장
# 사용하는 DB 계정명은 변수로 관리 (list) --> 사용하는 DB 계정 갯수에 무관하에 동작

# 사전 작업
# DB 기반 비밀 번호 변경 시 아래와 같이 시크릿 엔진 구성 후 작업 필요.
# 1.DB 시크릿 엔진 구성 
# 1.1 Connection : Admin 계정을 사용하여 연결 scbk01
# export VAULT_ADDR=
# export VAULT_TOKEN=
#vault write database/config/dbuidbs \
#    plugin_name=postgresql-database-plugin \
#    allowed_roles="*" \
#    connection_url="postgresql://{{username}}:{{password}}@localhost:5432/postgres?sslmode=disable" \
#    username="scbk01" \
#    password="test"
# 1.2 Role 구성 : DB 계정별로 Role 생성 : uidbs01h, uidbs02h, uidbs03h 
#vault write database/static-roles/uidbs01h \
#    db_name=dbuidbs \
#    rotation_statements="alter user {{name}} with password '{{password}}'" \
#    username="uidbs01h" \
#    rotation_period=60
#vault write database/static-roles/uidbs02h \
#    db_name=dbuidbs \
#    rotation_statements="alter user {{name}} with password '{{password}}'" \
#    username="uidbs02h" \
#    rotation_period=60
#vault write database/static-roles/uidbs03h \
#    db_name=dbuidbs \
#    rotation_statements="alter user {{name}} with password '{{password}}'" \
#    username="uidbs03h" \
#    rotation_period=60
# rotation_statements=@rotation.sql \


# 1. DB 시크릇 엔진 기반 Password 변경
data "vault_generic_secret" "pwd_rotate" {
    for_each = toset(var.db_ids)
    path = "database/static-creds/${each.key}"
}


# 2 Consul K/V :DB 비밀 번호 변경 하는 경우
resource "consul_keys" "rotated_pwd" {
    datacenter = var.consul_dc
    for_each = toset(var.db_ids)
    key {
        path = "pwd/ibanking/p_pw/${each.key}"
        value = nonsensitive(lookup((data.vault_generic_secret.pwd_rotate["${each.key}"].data), "password", "what?"))
    }

}


# 생성된 Password 가져오기
data "consul_key_prefix" "target_pwd" {
      datacenter = var.consul_dc
  #  for_each = toset(var.db_ids)
 # key {
  #  name = "gen_passwd"
  # path = "pwd/ibanking/p_pw/${each.key}"
   path_prefix = "pwd/ibanking/p_pw/"
 # }
}

# 3. 저장된 KV 암호화
# 암호화 모듈이 있는 서버의 shell 또는 명령어를 호출
# 4. 암호화된 PWD를 Consul KV에 저장
# 3번의 실행 결과를 입력값으로 받아, 바로 Consul에 저장.
# 암호화 서버에만 접속하는 형태로 수정
resource "null_resource" "enc_pwd" {
     triggers = {
         buildtime = timestamp()
     }
    for_each = (data.consul_key_prefix.target_pwd.subkeys)
    provisioner "local-exec" {
        # Different for every Encryption method
        # 암호화 방법에 따라 /opt/jboss/bin/enc.sh ${each.key}를 수정. 
        # 예제의 경우, 해당 서버의 /opt/jboss/bin/enc.sh 'TEST'라고 수행 시 TEST를 암호화하는 방식
        command = "consul kv put pwd/ibanking/enc_pwd/'${each.key}' `sshpass -p '${var.hcv_passwd}' ssh '${var.hcv_user}'@'${var.enc_srv}' '/opt/jboss/bin/enc.sh '${each.value}''` "
       
    }
    depends_on = [consul_keys.rotated_pwd]
}

#output "tst" {
#  #for_each = toset(var.db_ids)
#value= (values(data.consul_key_prefix.target_pwd.subkeys))
#}