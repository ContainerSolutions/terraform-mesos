resource "google_compute_firewall" "mesos-http" {
    name = "${var.name}-mesos-http"
    network = "${google_compute_network.mesos-net.name}"

    allow {
        protocol = "tcp"
        ports = ["80"]
    }

    target_tags = ["http"]
    source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_firewall" "mesos-https" {
    name = "${var.name}-mesos-https"
    network = "${google_compute_network.mesos-net.name}"

    allow {
        protocol = "tcp"
        ports = ["443"]
    }

    target_tags = ["http"]
    source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_firewall" "mesos-ssh" {
    name = "${var.name}-mesos-ssh"
    network = "${google_compute_network.mesos-net.name}"

    allow {
        protocol = "tcp"
        ports = ["22"]
    }

    target_tags = ["ssh"]
    source_ranges = ["0.0.0.0/0"]
}
