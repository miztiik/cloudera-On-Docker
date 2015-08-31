##!/usr/bin/perl
##################################################################################
##	Author			:	Miztiik
##	Date   			:	31Aug2015
##	Version			:	0.4
##	Description		:	This script is to used to create a dockerHost running centos7 from minimal DVD
##	Assumptions		:	BaseOS Image - Centos 7
##################################################################################

# Setup up Google OpenDNS Servers
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf

more /etc/sysconfig/network

cat > /etc/sysconfig/network << "EOF"
NETWORKING=yes
HOSTNAME=dockerHostCentOS7
DNS1=8.8.8.8
DNS2=8.8.4.4
EOF

# If Centos7 to make the interfaces have pretty names - editing /etc/default/grub and adding "net.ifnames=0 biosdevname=0" to GRUB_CMDLINE_LINUX variable.
sed -ri 's/GRUB_CMDLINE_LINUX="rhgb quiet"/GRUB_CMDLINE_LINUX="rhgb quiet net.ifnames=0 biosdevname=0"/g' /etc/default/grub
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
HOSTNANE=dockerHostCentOS7
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
DNS1=8.8.8.8
MTU=1500
DELAY=0
EOF


# Restart the network for the new n/w configs to take into effect
systemctl restart network

# Installing and Configuring the Software
	# Check and install if you have EPEL Packages.
# https://fedoraproject.org/wiki/EPEL
yum -y install epel-release && yum clean all

# Edit /etc/yum.conf so that docs are not installed to keep the image size small
echo "tsflags=nodocs" >> /etc/yum.conf

# Setup yum to use caching in the shared folder to allow it to be reused by multiple systems, number of copies to 3
sed -ri 's/keepcache=0/keepcache=1/g' /etc/yum.conf
sed -ri 's/installonly_limit=5/installonly_limit=3/g' /etc/yum.conf

# For Centos 7
yum -y install deltarpm && yum clean all

#Les update the server before guest additions need to be compiled
yum -y update && yum clean all

# Setup the ssh keys - passwordless ssh
ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys

reboot

# To make the image size smaller, lets keep the number of kernels to just 1 ( OPTIONAL )
rpm -qa kernel
yum remove <old-kernel-versions>

# Setting up the binaries for Virtualbox Guest additions
yum -y install gcc kernel-headers-$(uname -r) perl bzip2 dkms && yum clean all

# Mount the ISO image with the guest additions
mkdir /cdrom
mount /dev/cdrom /cdrom
/cdrom/VBoxLinuxAdditions.run

reboot

# Have to really escape the special chracters will back slashes, probably should find a neater way of doing this, (laterz..)
# This will not work unless Virtualbox Guest additions are already installed.
sed -ri 's/cachedir=\/var\/cache\/yum\/\$basearch\/\$releasever/cachedir=\/media\/sf_dockerRepos\/dockerTmp\/yum\/\$basearch\/\$releasever/g' /etc/yum.conf

# Set selinux to allow access to the VirtualBox Shared Folder
chcon -Rt svirt_sandbox_file_t /media/sf_dockerRepos/dockerBckUps
# If the above doesn't solve it
sestatus 0

# If you want to disable selinuc permenently do it here /etc/selinux/config

# Setup Command alias to access the shared folder
echo "alias repos='cd /media/sf_dockerRepos'" >> /root/.bashrc
source /root/.bashrc

# Set the iptables to allow for weave to work
# https://github.com/weaveworks/weave/issues/1266
iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited
iptables -D FORWARD -j REJECT --reject-with icmp-host-prohibited

# For disabling selinux permenently
# vi /etc/selinux/config
# SELINUX=permissive

# Reload the firewall configuration and make it permenent
firewall-cmd --reload
firewall-cmd --permanent

# OPTIONAL
# Stop logging for mail, uucp, boot etc (not going to run the m/c permenently, shouldnt be doing for test & production machines)

##################################################################################
## Here ends the configs on the operating system level
##################################################################################


##################################################################################
## Docker Installation & Configuration BEGINS
##################################################################################

# Now we are ready to install docker - http://wiki.centos.org/Cloud/Docker
# For Centos 7
curl -sSL https://get.docker.com/ | sh
# yum -y install docker-engine

# Once docker is installed, you will need to start the service in order to use it.
systemctl start docker

# To start the docker service on boot:
systemctl enable docker

# Adding your user to docker group to run docker (lets setup one more username "hadoopadmin")
useradd hadoopadmin
# echo <password> | passwd hadoopadmin --stdin
echo 'hadoopadmin:tcuser' | chpasswd
usermod -aG docker hadoopadmin

# Modify the defaults so docker uses different location for images and containers
# https://forums.docker.com/t/how-do-i-change-the-docker-image-installation-directory/1169
# On Centos/Fedora/RedHat that option is to be set in /etc/sysconfig/docker
# On Ubuntu that option is to be set in the /etc/default/docker

# Stop docker service docker stop
systemctl stop docker

# Probably could try to create a new disk and assign it but that disk will not be visible in the host nor can be shared with other containers. So for now giving up on this


# Location used for temporary files, such as those created by docker load and build operations
# DOCKER_TMPDIR=/media/sf_dockerRepos/dockerTmp

sed -ri 's/# DOCKER_TMPDIR=\/var\/tmp/DOCKER_TMPDIR=\/media\/sf_dockerRepos\/dockerTmp/g' /etc/sysconfig/docker

# Storage options are set in /etc/sysconfig/docker-storage
# Not using the storage options to and letting the images be in the default size
# DOCKER_STORAGE_OPTIONS= --storage-opt dm.basesize=5G --storage-opt dm.loopdatasize=5G
# --storage-opt dm.loopdatasize=500GB --storage-opt dm.loopmetadatasize=10GB

DOCKER_STORAGE_OPTIONS=

# DOCKER_STORAGE_OPTIONS=-s devicemapper -g /media/sf_dockerRepos/dockerImages/ --storage-opt dm.blocksize=64k --storage-opt dm.fs=xfs --storage-opt dm.thinpooldev=/dev/mapper/centos_dockerhost--centos7-docker--pool

# Restart docker
systemctl start docker

##################################################################################
## Docker Installation & Configuration ENDS
##################################################################################

# To pull docker centos image 6.6 from repository
docker pull centos:6.6
