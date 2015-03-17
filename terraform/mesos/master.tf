resource "google_compute_instance" "mesos-master" {
    count = "${var.masters}"
    name = "${var.name}-mesos-master-${count.index}"
    machine_type = "n1-standard-4"
    zone = "${var.zone}"
    tags = ["mesos-master","http","https","ssh"]
    
    disk {
      image = "ubuntu-os-cloud/ubuntu-1404-trusty-v20150128"
      type = "pd-ssd"
    }
    
    # network interface
    network_interface {
      network = "${google_compute_network.mesos-net.name}"
      access_config {
        nat_ip = "${element(google_compute_address.master-address.*.address, count.index)}"
      }
    }
    
    # define default connection for remote provisioners
    connection {
      user = "${var.gce_ssh_user}"
      key_file = "${var.gce_ssh_private_key_file}"
    }
    
    # install mesos, haproxy and docker
    provisioner "remote-exec" {
      scripts = ["../../scripts/master_install.sh", "../../scripts/docker_install.sh" ]
    }
    
    # set zk string
    provisioner "remote-exec" {
      inline = "sudo sh -c 'echo zk://${join(":2181,", google_compute_instance.mesos-master.*.name)}:2181/mesos > /etc/mesos/zk'"
    }

    #set myid
    provisioner "remote-exec" {
      inline = "sudo sh -c 'echo ${count.index} /etc/zookeeper/conf/myid'"
    }
    
    

}

