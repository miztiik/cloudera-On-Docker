#!/usr/bin/perl
###########################################################
#	Author : Miztiik
#	Date   : 12July2015
#	Version: 0.2
#	This script gives a template to create a docker host
#	In future will need to plan to integrate it with vagrant to automate it
#	Assumption is that all the commands are executed with root privileges
## TODO:
#	* 
###########################################################


## Installing and Configuring the Software
# Check and install if you have EPEL Packages.
# https://fedoraproject.org/wiki/EPEL
yum -y install epel-release

# Install yum presto
yum -y install yum-presto

yum -y update
yum -y clean all

# Get the network bridge virtualization bins
yum -y install libvirt bridge-utils libvirt-client python-virtinst

#Check network configs
cd /etc/sysconfig/network-scripts


## eth0 - in VirtualBox remains NAT for internet access
## eth1 - in VirtualBox remains "HostOnly Nework" to allow VMnetwork to communicate from the host and other VMs

## Lets create the NAT network for the eth0 card
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=dhcp
DELAY=0
EOF


#Lets create a static network on eth1 on the host
cat > /etc/sysconfig/network-scripts/ifcfg-eth1 << EOF
DEVICE=eth1
TYPE=Ethernet
ONBOOT=yes
BRIDGE=br0
BOOTPROTO=static
DELAY=0
EOF

## Now, lets set up the bridge br0 for the docker network
cat > /etc/sysconfig/network-scripts/ifcfg-br0 << EOF
HOSTNANE=dockerhost
DEVICE=eth1
ONBOOT=yes
BOOTPROTO=none
TYPE=Ethernet
NM_CONTROLLED=no
IPV6INIT=no
USERCTL=no
IPADDR=192.168.56.75
NETWORK=192.168.0.0
NETMASK=255.255.255.0
DNS1=192.168.0.1
MTU=1500
DELAY=0
EOF

## Now we are ready to install docker - http://wiki.centos.org/Cloud/Docker
yum -y install docker-io

## Once docker is installed, you will need to start the service in order to use it.
service docker start

## To start the docker service on boot:
chkconfig docker on

## Adding your user to docker group to run docker (lets setup one more username "hadoopadmin")
useradd hadoopadmin
echo <password> | passwd hadoopadmin --stdin
usermod -aG docker hadoopadmin

docker pull centos:6.6
