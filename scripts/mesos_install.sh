#!/bin/bash

# Setup
sudo dpkg -s mesos
if [ $? -eq 0 ]
	then
	echo "Mesos is already installed"
	exit $?
fi

if [ -z "$MESOS_VERSION" ]
	then
	MESOS_VERSION=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/mesosversion"`
	if [ -z "$MESOS_VERSION" ]
		then
		echo "$MESOS_VERSION is not set"
		exit 1
	fi
fi

# Add the repository
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)
echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | \
  sudo tee /etc/apt/sources.list.d/mesosphere.list
sudo apt-get -y update

# Generate locale
sudo locale-gen en_US.UTF-8

# Try to install Mesos from a package
sudo apt-get -y install mesos=$MESOS_VERSION-1.0.ubuntu1404

if [ $? -eq 0 ]
	then
	echo "Mesos $MESOS_VERSION installed"
	exit 0
fi

if [ -z "$PACKER_BUILD" ]
	then
	echo "There is no package for Mesos $MESOS_VERSION available. Please try to build it from sources into an image. More info: terraform-mesos/images/README.md"
	exit 1
fi

# Try to install Mesos from sources
sudo apt-get -y install git build-essential openjdk-6-jdk python-dev python-boto libcurl4-nss-dev libsasl2-dev maven libapr1-dev libsvn-dev autoconf libtool
mkdir /tmp/mesos
cd /tmp/mesos
git clone https://git-wip-us.apache.org/repos/asf/mesos.git .
git checkout $MESOS_VERSION
if [ $? -ne 0 ]
	then
	echo "Cannot find branch $MESOS_VERSION in Mesos git repository"
	exit 1
fi
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
