resource "google_compute_instance" "mesos-master" {
    count = "${var.masters}"
    name = "${var.name}-mesos-master-${count.index}"
    machine_type = "n1-standard-2"
    zone = "${var.zone}"
    tags = ["mesos-master","http","https","ssh","vpn"]
    
    disk {
      image = "ubuntu-os-cloud/ubuntu-1404-trusty-v20150128"
      type = "pd-ssd"
    }
    
    metadata {
      mastercount = "${var.masters}"
      clustername = "${var.name}"
      //zk = "zk://${join(":2181,", google_compute_instance.mesos-master.*.name)}:2181/mesos"
      myid = "${count.index}"
    }
    
    # network interface
    network_interface {
      network = "${google_compute_network.mesos-net.name}"
      access_config {
        // nat_ip = "${element(google_compute_address.master-address.*.address, count.index)}"
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
        "../../scripts/master_install.sh",
        "../../scripts/docker_install.sh",
        "../../scripts/common_config.sh",
        "../../scripts/master_config.sh"
      ]
    }
}

