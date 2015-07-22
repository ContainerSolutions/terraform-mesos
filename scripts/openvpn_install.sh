#!/bin/bash
HOSTNAME=`hostname`

#only install if hostame ends with 0 (only do this for the first master in the cluster)
if [ ${HOSTNAME: -1} -eq 0 ]
then
  sudo apt-get -y install openvpn easy-rsa
  sudo cp -r /usr/share/easy-rsa /etc/openvpn/

  cd /etc/openvpn/easy-rsa

  # set the default environment variables
  source vars

  # set environment variables
  export KEY_COUNTRY="NL"
  export KEY_PROVINCE="NH"
  export KEY_CITY="Amsterdam"
  export KEY_ORG="Container Solutions"
  export KEY_EMAIL="sysadmin@container-solutions.com"
  export KEY_CN="MesosVPN"
  export KEY_NAME="MesosVPN"
  export KEY_OU="MesosVPN"

  # start with an empty keys dir
  sudo -E ./clean-all

  #create ca
  sudo -E ./pkitool --initca

  #create server cert
  sudo -E ./pkitool --server $SERVERNAME

  #create diffie-hellman parameters
  sudo -E ./build-dh

  # create client cert
  sudo -E ./pkitool client1

fi
