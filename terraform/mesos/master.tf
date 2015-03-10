resource "google_compute_instance" "mesos-master" {
    count = "${var.mastercount}"
    name = "mesos-master${count.index}"
    machine_type = "n1-standard-4"
    zone = "${var.zone}"
    tags = ["mesos-master","http","https","ssh"]
    
    disk {
      image = "ubuntu-os-cloud/ubuntu-1404-trusty-v20150128"
      type = "pd-ssd"
    }
    
    network_interface {
      network = "${google_compute_network.mesos-net.name}"
      access_config {
        nat_ip = "${element(google_compute_address.master-address.*.address, count.index)}"
      }
    }

    provisioner "remote-exec" {
      scripts = ["../../scripts/master_install.sh", "../../scripts/docker_install.sh" ]
      connection {
        user = "${var.gce_ssh_user}"
        key_file = "${var.gce_ssh_private_key_file}"
      }
    }

    provisioner "remote-exec" {
      inline = "echo zk://${join(":2181,", google_compute_address.zookeeper-address.*.address)} > /etc/zookeeper"
      connection {
        user = "${var.gce_ssh_user}"
        key_file = "${var.gce_ssh_private_key_file}"
      }
    }

}

