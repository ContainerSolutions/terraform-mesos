# Container Solutions Terraform Mesos

## How to run Mesos cluster with Terraform

### Prepare Terraform configuration file

```
cp terraform/mesos/terraform.tfvars.example terraform/mesos/terraform.tfvars
```

- Get your Google Cloud JSON Key (Currently only Google Cloud provider is supported)
    - Visit https://console.developers.google.com
    - Navigate to APIs & Auth -> Credentials -> Service Account -> Generate new JSON key
    - Once you obtain the JSON key, enter its path to the Terraform configuration file as `account_file`

- Get Google Cloud SDK
    - Visit https://cloud.google.com/sdk/
    - Install the SDK and authenticate it with your Google Account
    - Once your keypair is created, enter its path and the username you created it for to the Terraform configuration file as `gce_ssh_user` and `gce_ssh_private_key_file`

- Specify `project`, `region` and `zone` of your Google Cloud Project to the configuration file

- Enter `name`, which will stand as a prefix of all the created objects

- Set Mesos master instances count as `masters` value

### Create Terraform plan

- Make sure you have Terraform installed

- Create the plan and save it to a file

```
terraform plan -out my.plan
```

### Create the cluster

```
terraform apply my.plan
```

### Destroy the cluster

```
terraform destroy
```

## Notes / Questions

- why does a resource have a name in the title, and an attribute?

```
resource "google_compute_network" "mesos-net" {
    name = "mesos-net"
    ...
}
```

- ~~destroy does not destroy everything at once, need to run twice (network can't be deleted because vm is still running)~~

- ~~network creation takes too long so node creation fails on first apply run.~~

## Things to take care of

(taken from <https://www.digitalocean.com/community/tutorials/how-to-configure-a-production-ready-mesosphere-cluster-on-ubuntu-14-04>)

- ~~logging into created vm with ssh (using https://www.terraform.io/docs/provisioners/connection.html)~~

- install software
    - ~~see ../scripts/master_install.sh and slave_install.sh~~
    - ~~install mesosphere on master nodes~~
    - ~~install mesos on slave nodes~~
    - ~~install haproxy on all nodes~~ (or mesos-dns?)
    - ~~install docker on all nodes~~

- configure zookeeper
    - ~~set id of master in `/etc/zookeeper/conf/myid` (unique for every master node)~~
    - ~~set ip and id of masters in `/etc/zookeeper/zoo.cfg` on every master node~~ (make sure the files are updated when masters change)

- configure mesos on master and slave nodes
    - ~~set url to all master nodes in `/etc/mesos/zk` on every master and slave node (```zk://master-ip:2181,master-ip:2181,master-ip:2181/mesos```)~~
    - ~~set quorum in ```/etc/mesos-master/quorum``` on every master node~~
    - ~~set host ip on every master node, in ```/etc/mesos-master/ip``` and ```/etc/mesos-master/hostname```~~

- ~~configure marathon on master nodes~~
    - ~~```sudo mkdir -p /etc/marathon/conf```~~
    - ~~```sudo cp /etc/mesos-master/hostname /etc/marathon/conf```~~
    - ~~```sudo cp /etc/mesos/zk /etc/marathon/conf/master```~~
    - ~~```sudo cp /etc/marathon/conf/master /etc/marathon/conf/zk```~~
    - ~~```sudo sed -i -e 's/mesos/marathon/' /etc/marathon/conf/zk```~~

- ~~restart services~~
    - on the master nodes
        - ~~```sudo stop mesos-slave```~~
        - ~~```echo manual | sudo tee /etc/init/mesos-slave.override```~~
        - ~~```sudo restart zookeeper```~~
        - ~~```sudo start mesos-master```~~
        - ~~```sudo start marathon```~~
    - on the slave nodes
        - ~~```sudo stop zookeeper```~~
        - ~~```echo manual | sudo tee /etc/init/zookeeper.override```~~
        - ~~```echo manual | sudo tee /etc/init/mesos-master.override```~~
        - ~~```sudo stop mesos-master```~~
        - ~~```echo 192.168.2.51 | sudo tee /etc/mesos-slave/ip```~~
        - ~~```sudo cp /etc/mesos-slave/ip /etc/mesos-slave/hostname```~~
        - ~~```sudo start mesos-slave```~~

- parameterize
    - ~~set name for cluster, to be used in network name, firewall rules names and hostnames~~
    - ~~allow for configuration of number of masters, slaves~~
    
  
