resource "google_compute_instance" "mesos-master" {
    name = "mesos-master"
    machine_type = "n1-standard-4"
    zone = "${var.zone}"
    tags = ["mesos-master","http","https","ssh"]
    
    disk {
      image = "ubuntu-os-cloud/ubuntu-1404-trusty-v20150128"
      type = "pd-ssd"
    }
    
    network_interface {
      network = "mesos-net"
      access_config {
        //Ephemeral IP
      }
    }
    
    provisioner "remote-exec" {
      script = "../../scripts/master_install.sh"
    }
    
    connection {
        user = "${var.gce_ssh_user}"
        key_file = "${var.gce_ssh_private_key_file}"
    }
}