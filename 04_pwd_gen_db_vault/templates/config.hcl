consul {
  address = "127.0.0.1:8500"

}

vault {}


log_level = "debug"

template {
  source = "./jboss_standalone_ha.tmpl"
  destination = "./jboss_standalone_ha.xml"

}