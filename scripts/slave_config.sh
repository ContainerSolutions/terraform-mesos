#!/bin/bash -e

MASTERCOUNT=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/mastercount"`
CLUSTERNAME=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/clustername"`

# disable services
sudo systemctl disable zookeeper.service || true
sudo systemctl disable mesos-master.service || true

# set hostname
IP=`curl -L -H "Metadata-Flavor: Google" http://metadata/computeMetadata/v1/instance/network-interfaces/0/ip`

sudo sh -c "echo ${IP} > /etc/mesos-slave/hostname"

# set containerizers
sudo sh -c "echo 'docker,mesos' > /etc/mesos-slave/containerizers"

# logging level
sudo sh -c "echo 'WARNING' > /etc/mesos-slave/logging_level"

# start the slave process
sudo systemctl start mesos-slave
exit 0
