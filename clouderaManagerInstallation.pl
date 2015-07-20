##!/usr/bin/perl
##################################################################################
##	Author 		: Miztiik
##	Date   		: 18Jul2015
##	Version		: 0.2
##	Assumptions	: BaseOS Image - Centos 6.6(max supported by Cloudera 5.x)
##				: My idea is to create seperate images/containers for each of the cloudera services
##################################################################################

# Version Levels used
#	Windows 7
#	Boot2Docker 1.7.0
#	Docker 1.7.0
#	CentOS 6.6 (Docker image from Centos Repos 6.6)
#	Cloudera 5.4.3
## Now lets setup Docker to be used as Name nodes(x 1) and Data nodes (x 2), Intitally we will try to setup with 3 containers.


# Cloudera Manager Node Installation

# Installing Cloudera repositories
# http://www.cloudera.com/content/cloudera/en/documentation/cdh5/v5-0-0/CDH5-Installation-Guide/cdh5ig_cdh5_install.html#topic_4_4_1_unique_1

# Download the repo and install it locally along with the GPG Key
curl -O http://archive.cloudera.com/cdh5/one-click-install/redhat/6/x86_64/cloudera-cdh-5-0.x86_64.rpm
yum -y --nogpgcheck localinstall cloudera-cdh-5-0.x86_64.rpm
rpm --import http://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera



# Change yum.conf to use external respository for cache to avoid bloating up the container/image

#cachedir=/var/cache/yum/$basearch/$releasever
cachedir=/media/sf_dockerRepos/dockerTmp/yum/$basearch/$releasever

# Ensure the cache is left on the cache directory
#keepcache=0
keepcache=1

# Attempting cloudera manager managed installation
cd /media/sf_dockerRepos/RPMs/
curl -O  http://archive.cloudera.com/cm5/installer/latest/cloudera-manager-installer.bin
chmod u+x cloudera-manager-installer.bin
/media/sf_dockerRepos/RPMs/cloudera-manager-installer.bin

# Installing resource manager
yum clean all
yum -y install hadoop-yarn-resourcemanager

yum install --downloadonly hadoop-yarn-resourcemanager

