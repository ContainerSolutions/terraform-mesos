backend "consul" {
  address = "127.0.0.1:8500"
  path = "vault"
  advertise_addr = "http://127.0.0.1:8500"
}

listener "tcp" {
  address = "127.0.0.1:8200"
  tls_disable = 1
}