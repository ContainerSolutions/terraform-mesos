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

# Try to install Mesos from sources
mkdir /tmp/mesos
cd /tmp/mesos
sudo apt-get -y install git ruby ruby-dev openjdk-7-jdk maven build-essential python-dev python-setuptools autoconf automake git make libssl-dev libcurl4-nss-dev libtool libsasl2-dev libapr1-dev libsvn-dev libunwind8
sudo gem install fpm
git clone https://github.com/ContainerSolutions/mesos-deb-packaging .
sudo ./build_mesos --ref $MESOS_VERSION --build-version $MESOS_VERSION
sudo dpkg -i pkg.deb
sudo dpkg-reconfigure mesos
# fix
sudo sed -i '/CLUSTER/d' /etc/default/mesos-master
# sudo apt-get -y install -f
