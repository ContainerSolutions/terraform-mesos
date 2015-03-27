resource "google_compute_network" "mesos-net" {
    name = "${var.name}-net"
    ipv4_range = "${var.network}"
}