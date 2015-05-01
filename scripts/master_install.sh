#!/bin/bash

# Setup
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)

# Add the repository
echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | \
  sudo tee /etc/apt/sources.list.d/mesosphere.list

#Generate the proper locale
sudo locale-gen nl_NL.UTF-8

#Update the packages
sudo apt-get -y update

#Install mesos
#sudo apt-get -y install mesosphere haproxy

#Install from source
#get dependencies
sudo apt-get -y install git build-essential openjdk-6-jdk python-dev python-boto libcurl4-nss-dev libsasl2-dev maven libapr1-dev libsvn-dev autoconf libtool

mkdir /tmp/mesos
cd /tmp/mesos
git clone https://git-wip-us.apache.org/repos/asf/mesos.git .

./bootstrap
mkdir build
cd build
../configure
make
#make check
sudo make install
