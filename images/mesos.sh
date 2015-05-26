#!/bin/bash

# Setup
MESOS_VERSION="0.22.1"
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)

# Add the repository
echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | \
  sudo tee /etc/apt/sources.list.d/mesosphere.list

# Generate the proper locale
sudo locale-gen en_US.UTF-8

# Install Mesos from source
sudo apt-get -y update
sudo apt-get -y install git build-essential openjdk-6-jdk python-dev python-boto libcurl4-nss-dev libsasl2-dev maven libapr1-dev libsvn-dev autoconf libtool
mkdir /tmp/mesos
cd /tmp/mesos
git clone https://git-wip-us.apache.org/repos/asf/mesos.git .
git checkout $MESOS_VERSION
./bootstrap
mkdir build
cd build
../configure
make
sudo make install

# Post install scripting
chmod +x /usr/bin/mesos-init-wrapper
mkdir -p /usr/share/doc/mesos /etc/default /etc/mesos /var/log/mesos
mkdir -p /etc/mesos-master /etc/mesos-slave /var/lib/mesos
cp ../CHANGELOG /usr/share/doc/mesos/
echo zk://localhost:2181/mesos > /etc/mesos/zk
echo /var/lib/mesos > /etc/mesos-master/work_dir
echo 1 > /etc/mesos-master/quorum
( cd /usr/local/lib && cp -s ../../lib/lib*.so . )
# ldconfig