provider "google" {
    credentials = "${file("${var.account_file}")}"
    project = "${var.project}"
    region = "${var.region}"
}
