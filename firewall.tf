resource "google_compute_firewall" "mesos-internal" {
    name = "${var.name}-mesos-internal"
    network = "${google_compute_network.mesos-global-net.name}"

    allow {
        protocol = "tcp"
        ports = ["1-65535"]
    }
    allow {
        protocol = "udp"
        ports = ["1-65535"]
    }
    allow {
        protocol = "icmp"
    }

    source_ranges = ["${google_compute_subnetwork.mesos-net.ip_cidr_range}"]

}

resource "google_compute_firewall" "mesos-http" {
    name = "${var.name}-${var.region}-mesos-http"
    network = "${google_compute_network.mesos-global-net.name}"

    allow {
        protocol = "tcp"
        ports = ["80"]
    }

    target_tags = ["http"]
    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "mesos-https" {
    name = "${var.name}-${var.region}-mesos-https"
    network = "${google_compute_network.mesos-global-net.name}"

    allow {
        protocol = "tcp"
        ports = ["443"]
    }

    target_tags = ["http"]
    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "mesos-ssh" {
    name = "${var.name}-${var.region}-mesos-ssh"
    network = "${google_compute_network.mesos-global-net.name}"

    allow {
        protocol = "tcp"
        ports = ["22"]
    }

    target_tags = ["ssh"]
    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "vpn" {
    name = "${var.name}-${var.region}-vpn"
    network = "${google_compute_network.mesos-global-net.name}"

    allow {
        protocol = "udp"
        ports = ["1194"]
    }

    target_tags = ["vpn"]
    source_ranges = ["0.0.0.0/0"]
}
