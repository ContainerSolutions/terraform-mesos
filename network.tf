resource "google_compute_network" "mesos-global-net" {
    name                    = "${var.name}-global-net"
    auto_create_subnetworks = false # custom subnetted network will be created that can support google_compute_subnetwork resources
}

resource "google_compute_subnetwork" "mesos-net" {
    name          = "${var.name}-${var.region}-net"
    ip_cidr_range = "${var.subnetwork}"
    network       = "${google_compute_network.mesos-global-net.self_link}" # parent network
}
