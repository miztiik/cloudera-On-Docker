##!/usr/bin/perl
##################################################################################
##	Author : Miztiik
##	Date   : 12July2015
##	Version: 0.2
##################################################################################
##	This script gives a template to create a Apache Flume Container
##	In future will need to plan to integrate it with vagrant to automate it
##	Assumption is that all the commands are executed with root privileges
## TODO:
##	* 
##								##			##
##								##	#	#	##									
##								##			##									
##								##			##									
##################################################################################

## The script needs to be run from inside the docker container

## Installing and Configuring the Software
## Check and install if you have EPEL Packages.
## https://fedoraproject.org/wiki/EPEL
yum -y install epel-release

## Install yum presto
yum -y install yum-presto

yum -y update
yum -y clean all

yum -y install tar

## Get the network bridge virtualization bins
yum -y install libvirt bridge-utils libvirt-client python-virtinst

## Check network configs
cd /etc/sysconfig/network-scripts

## Have sshd running for any troubleshooting issues
/usr/sbin/sshd -D
chkconfig sshd on

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

## Install from cloudera RPM
## Ref - http://www.cloudera.com/content/cloudera/en/documentation/cdh5/v5-0-0/CDH5-Installation-Guide/cdh5ig_flume_package_install.html
## Ref - http://probablyfine.co.uk/2014/05/05/using-docker-with-apache-flume-1/
## Ref - http://probablyfine.co.uk/2014/08/24/using-docker-with-apache-flume-2/

curl -O http://archive.cloudera.com/cdh5/one-click-install/redhat/6/x86_64/cloudera-cdh-5-0.x86_64.rpm
yum --nogpgcheck localinstall <path-to-rpm>/cloudera-cdh-5-0.x86_64.rpm

yum -y  install flume-ng flume-ng-agent

## flume gets installed in /etc/flume-ng
cd /etc/flume-ng/conf

## Copy from the default template use them as reference
cp -p flume-conf.properties.template flume.conf
cp -p flume-env.sh.template flume-env.sh

## Run the script for reference
/etc/flume-ng/conf/flume-env.sh

## Confirm flume is installed properly ( it should display the command options)
flume-ng help

## Starting the service and making to start along with boot - The second step is optional
service flume-ng-agent start
chkconfig flume-ng-agent on