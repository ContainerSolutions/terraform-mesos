resource "google_compute_address" "master-address" {
    count = "${var.mastercount}"
    name = "master-address${count.index}"
}

resource "google_compute_address" "zookeeper-address" {
    count = "${var.zookeepercount}"
    name = "master-address${count.index}"
}