provider "google" {
    account_file = "${file("${var.account_file}")}"
    project = "${var.project}"
    region = "${var.region}"
}