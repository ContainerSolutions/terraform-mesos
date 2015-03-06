resource "google_compute_address" "master-address" {
    count = "${var.mastercount}"
    name = "master-address${count.index}"
}