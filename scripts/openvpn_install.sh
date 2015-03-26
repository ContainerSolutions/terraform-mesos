#!/bin/bash
sudo apt-get -y install openvpn easy-rsa
sudo cp -r /usr/share/easy-rsa /etc/openvpn/

cd /etc/openvpn/easy-rsa

#create ca
sudo ./pkitool --initca

#create server cert
sudo ./pkitool --server $SERVERNAME

#create diffie-hellman parameters
sudo ./build-dh

# create client cert
sudo ./pkitool client1
