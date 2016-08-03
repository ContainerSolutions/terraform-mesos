#!/bin/bash -e

# Setup
sudo rpm -q mesos && {
	echo "Mesos is already installed"
	exit 0
}

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
sudo rpm -Uvh http://repos.mesosphere.com/el/7/noarch/RPMS/mesosphere-el-repo-7-3.noarch.rpm

# Generate locale
sudo localedef -c -i en_US -f UTF-8 en_US.UTF-8

# Try to install Mesos from a package
sudo yum -y install mesos-$MESOS_VERSION

if [ $? -eq 0 ]
	then
	echo "Mesos $MESOS_VERSION installed"
	exit 0
fi


exit 1
