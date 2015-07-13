#!/bin/bash

MASTERCOUNT=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/mastercount"`
CLUSTERNAME=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/clustername"`

# stop services if running
sudo stop zookeeper
sudo stop mesos-master

# disable services
sudo sh -c "echo manual > /etc/init/zookeeper.override"
sudo sh -c "echo manual > /etc/init/mesos-master.override"

# set hostname
HOSTNAME=`cat /etc/hostname`
IP=`host ${HOSTNAME}| grep ^${HOSTNAME}| awk '{print $4}'`

sudo sh -c "echo ${IP} > /etc/mesos-slave/hostname"
# set ip address
sudo sh -c "echo ${IP} > /etc/mesos-slave/ip"

# set containerizers
sudo sh -c "echo 'docker,mesos' > /etc/mesos-slave/containerizers"

# logging level
sudo sh -c "echo 'WARNING' > /etc/mesos-slave/logging_level"

# start the slave process
sudo start mesos-slave
