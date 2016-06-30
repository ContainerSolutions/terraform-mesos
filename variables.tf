## credential stuff
# path to the account file
variable "account_file" {}
# the username to connect with
variable "gce_ssh_user" {}
# the private key of the user
variable "gce_ssh_private_key_file" {}

## google project stuff
# the google region where the cluster should be created
variable "region" {}
# the google zone where the cluster should be created
variable "zone" {}
# the ID of the google project
variable "project" {}
# image to use for installation
variable "image" {
    default = "ubuntu-os-cloud/ubuntu-1504-vivid-v20151120"
}
variable "master_machine_type" {
    default = "n1-standard-2"
}
variable "slave_machine_type" {
    default = "n1-standard-4"
}

## network stuff
# the address of the subnet in CIDR
variable "subnetwork" {
    default = "10.20.30.0/24"
}
# domain name used by haproxy
variable "domain" {}

## mesos stuff
# mesos version
variable "mesos_version" {
	default = "0.26"
}
# the name of the cluster
variable "name" {}
# number of master nodes to install
variable "masters" {
    default = "1"
}
# number of slaves to install
variable "slaves" {
    default = "3"
}
# distribution redhat/ubuntu
variable "distribution" {
    default = "redhat"
}
