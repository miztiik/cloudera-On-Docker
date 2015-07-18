##!/usr/bin/perl
##################################################################################
##	Author 		: Miztiik
##	Date   		: 18Jul2015
##	Version		: 0.1
##	Description	: The VirtualBox documentation[1] for how to install guest additions for Linux on a virtual host is somewhat messy. 
## 				: To make it work with VirtualBox 4.3.12 & Guest Additions 4.3.14
##
##	[1] 		: http://www.virtualbox.org/manual/ch04.html
##	Assumptions	: BaseOS Image - Centos 7
##################################################################################

# For Centos 7
yum -y install deltarpm

# Setting up the binaries for Virtualbox Guest additions
yum -y install gcc kernel-headers-$(uname -r) perl bzip2 dkms

# If the above doesn't work try this
# yum -y install gcc kernel-headers-$(uname -r) perl bzip2 dkms kernel-devel-$(uname -r)

# Mount the ISO image with the guest additions
mkdir /cdrom
mount /dev/cdrom /cdrom
/cdrom/VBoxLinuxAdditions.run

yum -y update
yum -y clean all

reboot

# Share a folder from the VirtualBox control panel, giving it a share name.
ls  /media/sf_*

# You could always mount the directory yourself as well
# mkdir /a_folder_name 
# mount -t vboxsf the_share_name /a_folder_name



# In case you want to change the uid of the disk
# VBoxManage internalcommands sethduuid "<disk location>"