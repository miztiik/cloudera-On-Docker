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
#	
#	Ports Required
#	Clouder Manager Server 	:	7180
## Now lets setup Docker to be used as Name nodes(x 1) and Data nodes (x 2), Intitally we will try to setup with 3 containers.


# Cloudera Manager Node Installation

# Installing Cloudera repositories
# http://www.cloudera.com/content/cloudera/en/documentation/cdh5/v5-0-0/CDH5-Installation-Guide/cdh5ig_cdh5_install.html#topic_4_4_1_unique_1

# Download the repo and install it locally along with the GPG Key
curl -O http://archive.cloudera.com/cdh5/one-click-install/redhat/6/x86_64/cloudera-cdh-5-0.x86_64.rpm
rpm --import http://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera
yum -y --nogpgcheck localinstall cloudera-cdh-5-0.x86_64.rpm


# Install the cloudera Repository - link for CM5 - choose the appropriate one for your version
# http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cm_vd.html#concept_mb3_sfz_3q_unique_1
#( just in case you are using the manuall installation this will help)
cd /etc/yum.repos.d/
curl -O http://archive.cloudera.com/cm5/redhat/6/x86_64/cm/cloudera-manager.repo

# Should have been done in the image preparation script itself, If not last chance to do that here
# Change yum.conf to use external respository for cache to avoid bloating up the container/image

#cachedir=/var/cache/yum/$basearch/$releasever
cachedir=/media/sf_dockerRepos/dockerTmp/yum/$basearch/$releasever

# Ensure the cache is left on the cache directory
#keepcache=0
keepcache=1

# Disable iptables
chkconfig iptables off

# Disable selinux
setenforce 0

# Install Oracle
yum -y install oracle-j2sdk1.7

# Cloudera Manager Server Packages
yum -y install cloudera-manager-daemons cloudera-manager-server

# Installing and Starting the Cloudera Manager Server Embedded Database
yum -y install cloudera-manager-server-db-2
service cloudera-scm-server-db start

# ####################################################################
# Installing CD5 Manually
# The "hadoop-yarn" and "hadoop-hdfs" packages are installed on each system automatically as dependencies of the other packages.
	
# PREREQ 
# INSTALL - ZOOKEEPER
# http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cdh_ig_zookeeper_package_install.html
yum -y install zookeeper

mkdir -p /var/lib/zookeeper
chown -R zookeeper /var/lib/zookeeper/

service zookeeper-server init
service zookeeper-server start

# INSTALL - Resource Manager host
yum -y install hadoop-yarn-resourcemanager

# INSTALL - NameNode host
yum -y install hadoop-hdfs-namenode

# INSTALL - Secondary NameNode host (if used)
yum -y hadoop-hdfs-secondarynamenode

# INSTALL - All cluster hosts except the Resource Manager
yum -y install hadoop-yarn-nodemanager hadoop-hdfs-datanode hadoop-mapreduce


# INSTALL - Proxy (preferably secondary namenode)
yum -y install hadoop-mapreduce-historyserver hadoop-yarn-proxyserver

# INSTALL - All clients
yum -y install hadoop-client


# Attempting cloudera manager managed installation
cd /media/sf_dockerRepos/RPMs/
curl -O  http://archive.cloudera.com/cm5/installer/latest/cloudera-manager-installer.bin
chmod u+x cloudera-manager-installer.bin
/media/sf_dockerRepos/RPMs/cloudera-manager-installer.bin

# Installing resource manager
yum clean all
yum -y install hadoop-yarn-resourcemanager

yum install --downloadonly hadoop-yarn-resourcemanager

