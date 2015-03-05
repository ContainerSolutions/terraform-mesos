resource "google_compute_firewall" "mesos-http" {
    name = "mesos-http"
    network = "${google_compute_network.mesos-net.name}"

    allow {
        protocol = "tcp"
        ports = ["80"]
    }

    target_tags = ["http"]
    source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_firewall" "mesos-https" {
    name = "mesos-https"
    network = "${google_compute_network.mesos-net.name}"

    allow {
        protocol = "tcp"
        ports = ["443"]
    }

    target_tags = ["http"]
    source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_firewall" "mesos-ssh" {
    name = "mesos-ssh"
    network = "${google_compute_network.mesos-net.name}"

    allow {
        protocol = "tcp"
        ports = ["22"]
    }

    target_tags = ["ssh"]
    source_ranges = ["0.0.0.0/0"]
}
