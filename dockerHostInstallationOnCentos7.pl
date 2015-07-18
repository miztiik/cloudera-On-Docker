##!/usr/bin/perl
##################################################################################
##	Author 		: Miztiik
##	Date   		: 17Jul2015
##	Version		: 0.1
##	Description	: This script is to used to create a dockerHost running centos7 from minimal DVD
##	Assumptions	: BaseOS Image - Centos 7
##################################################################################

#Check network configs

cat > /etc/resolv.conf << EOF
search example.com
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
	
more /etc/sysconfig/network

cat > /etc/sysconfig/network << EOF
NETWORKING=yes
HOSTNAME=dockerHostCentos7.example.com
DNS1=8.8.8.8
DNS2=8.8.4.4
EOF

# If Centos7 to make the interfaces have pretty names - editing /etc/default/grub and adding "net.ifnames=0 biosdevname=0" to GRUB_CMDLINE_LINUX variable.
# net.ifnames=0 biosdevname=0
grub2-mkconfig -o /boot/grub2/grub.cfg
cd /etc/sysconfig/network-scripts
mv ifcfg-enp0s3 ifcfg-eth0
mv ifcfg-enp0s8 ifcfg-eth1

# To remove the old device MAC Address (OPTIONAL)
rm -r /etc/udev/rules.d/70-persistent-net.rules

# eth0 - in VirtualBox remains NAT for internet access
# eth1 - in VirtualBox remains "HostOnly Nework" to allow VMnetwork to communicate from the host and other VMs

# Lets create the NAT network for the eth0 card
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=dhcp
DELAY=0
EOF

#Lets create a static network on eth1 on the host
cat > /etc/sysconfig/network-scripts/ifcfg-eth1 << EOF
HOSTNANE=dockerHostCentos7
DEVICE=eth1
ONBOOT=yes
BOOTPROTO=none
TYPE=Ethernet
NM_CONTROLLED=no
IPV6INIT=no
USERCTL=no
IPADDR=192.168.56.85
NETWORK=192.168.0.0
NETMASK=255.255.255.0
DNS1=192.168.0.1
MTU=1500
DELAY=0
EOF


# Restart the network for the new n/w configs to take into effect
systemctl restart network

# Installing and Configuring the Software
# Check and install if you have EPEL Packages.
# https://fedoraproject.org/wiki/EPEL
yum -y install epel-release

# Edit /etc/yum.conf so that docs are not installed to keep the image size small
echo "tsflags=nodocs" >> /etc/yum.conf

# For Centos 7
yum -y install deltarpm

#Les update the server before guest additions need to be compiled
yum -y update
yum -y clean all

# To make the image size smaller, lets keep the number of kernels to just 1 ( OPTIONAL )
rpm -qa kernel
yum remove <old-kernel-versions>

reboot

# Setting up the binaries for Virtualbox Guest additions
yum -y install gcc kernel-headers-$(uname -r) perl bzip2 dkms

# If the above doesn't work try this
# yum -y install gcc kernel-headers-$(uname -r) perl bzip2 dkms kernel-devel-$(uname -r)

# Mount the ISO image with the guest additions
mkdir /cdrom
mount /dev/cdrom /cdrom
/cdrom/VBoxLinuxAdditions.run

reboot

##################################################################################
## Here ends the configs on the operating system level
##################################################################################


##################################################################################
## Docker Installation & Configuration BEGINS
##################################################################################

# Now we are ready to install docker - http://wiki.centos.org/Cloud/Docker
# For Centos 7
yum -y install docker

# Once docker is installed, you will need to start the service in order to use it.
systemctl start docker

# To start the docker service on boot:
systemctl enable docker

# Adding your user to docker group to run docker (lets setup one more username "hadoopadmin")
useradd hadoopadmin
echo <password> | passwd hadoopadmin --stdin
usermod -aG docker hadoopadmin

# Modify the defaults so docker uses different location for images and containers
# https://forums.docker.com/t/how-do-i-change-the-docker-image-installation-directory/1169
# On Centos/Fedora/RedHat that option is to be set in /etc/sysconfig/docker
# On Ubuntu that option is to be set in the /etc/default/docker
# Stop docker service docker stop
systemctl stop docker
# Verify no docker process is running 
ps faux

# Add this line to the defautls
# Add the google dns servers and the mount point for docker images and container data
# Probably could try to create a new disk and assign it but that disk will not be visible in the host nor can be shared with other containers. So for now giving up on this
# OPTIONS='--selinux-enabled --dns 8.8.8.8 --dns 8.8.4.4 -g /media/sf_dockerRepos/imageRepoOnCentos7'

# To enable debug mode
# OPTIONS='-d -D --dns 8.8.8.8 --dns 8.8.4.4'
OPTIONS='--dns 8.8.8.8 --dns 8.8.4.4'

# Location used for temporary files, such as those created by docker load and build operations
DOCKER_TMPDIR=/media/sf_dockerRepos/dockerTmp

# Storage options are set in /etc/sysconfig/docker-storage
# Not using the storage options to and letting the images be in the default size
# DOCKER_STORAGE_OPTIONS= --storage-opt dm.basesize=2G --storage-opt dm.loopdatasize=4G


# Restart docker
systemctl start docker

##################################################################################
## Docker Installation & Configuration ENDS
##################################################################################




