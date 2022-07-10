service {

  name = "n2"
  id = "n2"
  port = 22

check = {
  id = "ssh"
  name = "SSH TCP on port 22"
  tcp = "192.168.35.21:22"
  interval = "10s"
  timeout = "1s"
}
}