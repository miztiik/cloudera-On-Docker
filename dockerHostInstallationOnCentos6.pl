##!/usr/bin/perl
##################################################################################
##	Author 		: Miztiik
##	Date   		: 20Jul2015
##	Version		: 0.2
##	Description	: This script is to used to create a dockerHost running centos6.6 from minimal DVD
##	Assumptions	: BaseOS Image - Centos 6.6(max supported by Cloudera 5.x)
##################################################################################

#Check network configs

cat > /etc/resolv.conf << EOF
search example.com
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
	
# more /etc/sysconfig/network
# NETWORKING=yes
# HOSTNAME=dockerhost.example.com

cat > /etc/sysconfig/network << EOF
NETWORKING=yes
HOSTNAME=dockerhost.example.com
DNS1=8.8.8.8
DNS2=8.8.4.4
EOF

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


# Restart the network for the new n/w configs to take into effect
service network restart

# Installing and Configuring the Software
# Check and install if you have EPEL Packages.
# https://fedoraproject.org/wiki/EPEL
yum -y install epel-release

# Edit /etc/yum.conf so that docs are not installed to keep the image size small
echo "tsflags=nodocs" >> /etc/yum.conf

# Setup yum to use caching in the shared folder to allow it to be reused by multiple systems, number of copies to 3
sed -ri 's/keepcache=0/keepcache=1/g' /etc/yum.conf
sed -ri 's/installonly_limit=5/installonly_limit=3/g' /etc/yum.conf

# Have to really escape the special chracters will back slashes, probably should find a neater way of doing this, (laterz..)
sed -ri 's/cachedir=\/var\/cache\/yum\/\$basearch\/\$releasever/cachedir=\/media\/sf_dockerRepos\/dockerTmp\/yum\/\$basearch\/\$releasever/g' /etc/yum.conf

# Install yum presto (for Centos 6)
yum -y install yum-presto

yum -y update
yum -y clean all

# To make the image size smaller, lets keep the number of kernels to just 1 ( OPTIONAL )
rpm -qa kernel
yum remove <old-kernel-versions>

# Setup the ssh keys
cd /root
ssh-keygen
#Press enter twice
chmod 700 /root/.ssh
cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

reboot

# Setting up the binaries for Virtualbox Guest additions
yum -y install gcc kernel-devel perl

# Mount the ISO image with the guest additions
mkdir /cdrom
mount /dev/cdrom /cdrom
/cdrom/VBoxLinuxAdditions.run

reboot

# Set selinux to allow access to the VirtualBox Shared Folder
chcon -Rt svirt_sandbox_file_t /media/sf_dockerRepos/dockerBckUps
# If the above doesn't solve it
sestatus 0

# Setup Command alias to access the shared folder
echo "alias repos='cd /media/sf_dockerRepos'" >> /root/.bashrc
source /root/.bashrc

# OPTIONAL
# Stop logging for mail, uucp, boot etc (not going to run the m/c permenently, shouldnt be doing for test & production machines)

##################################################################################
## Here ends the configs on the operating system level
##################################################################################


##################################################################################
## Docker Installation & Configuration BEGINS
##################################################################################
# Now we are ready to install docker - http://wiki.centos.org/Cloud/Docker
# For Centos 6
yum -y install docker-io

# Once docker is installed, you will need to start the service in order to use it.
service docker start

# To start the docker service on boot:
chkconfig docker on

# Adding your user to docker group to run docker (lets setup one more username "hadoopadmin")
useradd hadoopadmin
echo <password> | passwd hadoopadmin --stdin
usermod -aG docker hadoopadmin

# Modify the defaults so docker uses different location for images and containers
# https://forums.docker.com/t/how-do-i-change-the-docker-image-installation-directory/1169
# On Centos/Fedora/RedHat that option is to be set in /etc/sysconfig/docker
# On Ubuntu that option is to be set in the /etc/default/docker
# Stop docker service docker stop
service docker stop
# Verify no docker process is running 
ps faux | grep -i docker

# Add this line to the defaults
# Add the google dns servers and the mount point for docker images and container data - The mounts are not working with virtualBox Shared Folders
# Probably could try to create a new disk and assign it but that disk will not be visible in the host nor can be shared with other containers. So for now giving up on this
# other_args="--dns 8.8.8.8 --dns 8.8.4.4 -g /media/sf_dockerRepos/dockerImages --storage-opt dm.basesize=2G --storage-opt dm.loopdatasize=4G"

# To enable debug mode
# other_args="-d -D --dns 8.8.8.8 --dns 8.8.4.4"
other_args="--dns 8.8.8.8 --dns 8.8.4.4"

# sed -ri 's/other_args=/other_args=--dns 8.8.8.8 --dns 8.8.4.4/g' /etc/sysconfig/docker

# Location used for temporary files, such as those created by docker load and build operations
# DOCKER_TMPDIR=/media/sf_dockerRepos/dockerTmp

sed -ri 's/# DOCKER_TMPDIR=\/var\/tmp/DOCKER_TMPDIR=\/media\/sf_dockerRepos\/dockerTmp/g' /etc/sysconfig/docker

# Storage options are set in /etc/sysconfig/docker-storage
# Not using the storage options to and letting the images be in the default size
# DOCKER_STORAGE_OPTIONS= --storage-opt dm.basesize=2G --storage-opt dm.loopdatasize=4G

# Restart docker
service docker start

##################################################################################
## Docker Installation & Configuration ENDS
##################################################################################

# To pull docker centos image 6.6 from repository
docker pull centos:6.6

