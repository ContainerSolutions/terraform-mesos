resource "google_compute_address" "master-address" {
    count = "${var.masters}"
    name = "${var.name}-master-address-${count.index}"
}