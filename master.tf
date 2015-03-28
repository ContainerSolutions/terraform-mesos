resource "google_compute_instance" "mesos-master" {
    count = "${var.masters}"
    name = "${var.name}-mesos-master-${count.index}"
    machine_type = "${var.master_machine_type}"
    zone = "${var.zone}"
    tags = ["mesos-master","http","https","ssh","vpn"]
    
    disk {
      image = "${var.image}"
      type = "pd-ssd"
    }

    # declare metadata for configuration of the node
    metadata {
      mastercount = "${var.masters}"
      clustername = "${var.name}"
      myid = "${count.index}"
    }
    
    # network interface
    network_interface {
      network = "${google_compute_network.mesos-net.name}"
      access_config {
        // ephemeral address
      }
    }
    
    # define default connection for remote provisioners
    connection {
      user = "${var.gce_ssh_user}"
      key_file = "${var.gce_ssh_private_key_file}"
    }
    
    # install mesos, haproxy, docker, openvpn, and configure the node
    provisioner "remote-exec" {
      scripts = [
        "scripts/master_install.sh",
        "scripts/docker_install.sh",
        "scripts/openvpn_install.sh",
        "scripts/common_config.sh",
        "scripts/master_config.sh"
      ]
    }
}

