resource "google_compute_instance" "mesos-slave" {
    count = "${var.slaves}"
    name = "${var.name}-mesos-slave-${count.index}"
    machine_type = "${var.slave_machine_type}"
    zone = "${var.zone}"
    tags = ["mesos-slave","http","https","ssh"]

    disk {
      image = "${var.image}"
      type = "pd-ssd"
    }

    metadata {
      mastercount = "${var.masters}"
      clustername = "${var.name}"
      domain = "${var.domain}"
      mesosversion = "${var.mesos_version}"
      slave_resources = "${var.slave_resources}"
    }

    service_account {
       scopes = ["userinfo-email", "compute-ro", "storage-ro"]
    }

    network_interface {
      subnetwork = "${google_compute_subnetwork.mesos-net.name}"
      access_config {
        //Ephemeral IP
      }
    }

    # define default connection for remote provisioners
    connection {
      user = "${var.gce_ssh_user}"
      key_file = "${var.gce_ssh_private_key_file}"
    }

    # install mesos, haproxy and docker
    provisioner "remote-exec" {
      scripts = [
        "${path.module}/scripts/common_install_${var.distribution}.sh",
        "${path.module}/scripts/mesos_install_${var.distribution}.sh",
        "${path.module}/scripts/haproxy_install.sh",
        "${path.module}/scripts/common_config.sh",
        "${path.module}/scripts/slave_config.sh"
      ]
    }
}
