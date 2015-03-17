resource "google_compute_network" "mesos-net" {
    name = "${var.name}-net"
    ipv4_range = "10.20.30.0/24"
}