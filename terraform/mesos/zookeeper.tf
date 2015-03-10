resource "google_compute_instance" "zookeeper" {
    count = "${var.zookeepercount}"
    name = "zookeeper${count.index}"
    machine_type = "n1-standard-4"
    zone = "${var.zone}"
    tags = ["zookeeper","http","https","ssh"]
    
    disk {
      image = "ubuntu-os-cloud/ubuntu-1404-trusty-v20150128"
      type = "pd-ssd"
    }
    
    network_interface {
      network = "${google_compute_network.mesos-net.name}"
      access_config {
        nat_ip = "${element(google_compute_address.zookeeper-address.*.address, count.index)}"
      }
    }

}


