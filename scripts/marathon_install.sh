#!/bin/bash

################################
sudo apt-get -y install marathon
################################

# Setup
sudo dpkg -s marathon
if [ $? -eq 0 ]
	then
	echo "Marathon is already installed"
	exit $?
fi

if [ -z "$MARATHON_VERSION" ]
	then
	MARATHON_VERSION=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/marathonversion"`
	if [ -z "$MARATHON_VERSION" ]
		then
		echo "$MARATHON_VERSION is not set"
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

# Try to install Marathon from a package
sudo apt-get -y install marathon=$MARATHON_VERSION-1.0.ubuntu1404

if [ $? -eq 0 ]
	then
	echo "Marathon $MARATHON_VERSION installed"
	exit 0
fi

# Try to install Marathon from sources
mkdir /tmp/marathon
cd /tmp/marathon
sudo apt-get -y install dpkg-dev git ruby ruby-dev openjdk-7-jdk
echo "deb http://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
sudo apt-get -y --force-yes install sbt
sudo gem install fpm
git clone https://github.com/deric/marathon-deb-packaging .
sudo ./build_marathon --ref $MARATHON_VERSION --build-version $MARATHON_VERSION
sudo dpkg -i pkg.deb
sudo apt-get -y install -f

# echo "deb http://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
# sudo apt-get -y update
# sudo apt-get -y install openjdk-7-jdk
# sudo apt-get -y --force-yes install sbt
# mkdir /tmp/marathon
# cd /tmp/marathon
# git clone https://github.com/mesosphere/marathon.git .
# git checkout $MARATHON_VERSION
# if [ $? -ne 0 ]
# 	then
# 	echo "Cannot find branch $MARATHON_VERSION in Marathon git repository"
# 	exit 1
# fi
# sbt assembly
# # ./bin/build-distribution

