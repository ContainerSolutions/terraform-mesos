#!/bin/bash -e
HOSTNAME=`hostname`

#only install if hostname ends with 0 (only do this for the first master in the cluster)
if [ ${HOSTNAME: -1} -eq 0 ]
then
  # install packages
  sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  sudo yum install -y openvpn easy-rsa

  # use default openvpn configuration
  cd /etc/openvpn
  sudo cp  /usr/share/doc/openvpn*/sample/sample-config-files/server.conf server.conf > /dev/null
  echo "dh2048.pem" | sudo tee dh2048.pem > /dev/null
  sudo sed -i 's/dh dh1024.pem/dh dh2048.pem/g' server.conf
  sudo sed -i "s/;user nobody/user nobody/g" server.conf
  sudo sed -i "s/;group nogroup/group nogroup/g" server.conf
  NETWORK=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/network" | cut -f1 -d"/")
  echo "push \"route ${NETWORK} 255.255.255.0\"" | sudo tee -a server.conf > /dev/null
  echo "tun-mtu 1400" | sudo tee -a server.conf > /dev/null
  echo "mssfix 1360" | sudo tee -a server.conf > /dev/null
  sudo sed -i "s/;duplicate-cn/duplicate-cn/g" server.conf
  sudo cp -r /usr/share/easy-rsa .
  sudo mkdir -p easy-rsa/keys

  # enable ip forwarding
  echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null
  sudo sysctl -w net.ipv4.ip_forward=1
  # adjust sysctl settings so they survive a reboot
  sudo sed -i 's/net.ipv4.ip_forward=0/net.ipv4.ip_forward=1/' /etc/sysctl.d/11-gce-network-security.conf

  # configure keys
  cd /etc/openvpn/easy-rsa/2.0
  source vars
  export KEY_COUNTRY="NL"
  export KEY_PROVINCE="NH"
  export KEY_CITY="Amsterdam"
  export KEY_ORG="Container Solutions"
  export KEY_EMAIL="sysadmin@container-solutions.com"
  export KEY_NAME="server"

  # generate the Diffie-Hellman parameters
  sudo openssl dhparam -out /etc/openvpn/dh2048.pem 2048

  # start with an empty keys dir
  sudo -E ./clean-all

  # create ca
  sudo -E ./pkitool --initca

  # create server cert
  sudo -E ./pkitool --server $KEY_NAME

  # copy server certificates and key
  sudo cp keys/{server.crt,server.key,ca.crt} /etc/openvpn

  # enable systemd service
  sudo systemctl enable openvpn@server.service

  # start openvpn
  sudo systemctl start openvpn@server.service

  # enable whole network on vpn
  sudo firewall-cmd --add-masquerade
  sudo firewall-cmd --permanent --add-masquerade

  # create client certificates
  sudo -E ./pkitool client1

  # template client config file
  mkdir ~/openvpn && cd ~/openvpn
  sudo cp /usr/share/doc/openvpn*/sample/sample-config-files/client.conf client.ovpn

  # update client configuration
  IP=$(curl -fsSL -H "Metadata-Flavor: Google" http://169.254.169.254/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)
  sudo sed -i "s/remote my-server-1 1194/remote ${IP} 1194/g" client.ovpn
  sudo sed -i "s/;user nobody/user nobody/g" client.ovpn
  sudo sed -i "s/;group nogroup/group nogroup/g" client.ovpn
  sudo sed -i "s/ca ca.crt/;ca ca.crt/g" client.ovpn
  sudo sed -i "s/cert client.crt/;cert client.crt/g" client.ovpn
  sudo sed -i "s/key client.key/;key client.key/g" client.ovpn
  echo -e "\n<ca>\n$(sudo cat /etc/openvpn/easy-rsa/2.0/keys/ca.crt)\n</ca>\n" | sudo tee -a client.ovpn > /dev/null
  echo -e "\n<cert>\n$(sudo cat /etc/openvpn/easy-rsa/2.0/keys/client1.crt)\n</cert>\n" | sudo tee -a client.ovpn > /dev/null
  echo -e "\n<key>\n$(sudo cat /etc/openvpn/easy-rsa/2.0/keys/client1.key)\n</key>\n" | sudo tee -a client.ovpn > /dev/null
fi
