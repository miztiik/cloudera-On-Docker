#!/bin/bash
set -x
##################################################################################
##	Author 		: Miztiik
##	Date   		: 27Jul2015
##	Version		: 0.1
##	Assumptions	: BaseOS Image - Centos 6.6(max supported by Cloudera 5.x)
##				: My idea is to create seperate images/containers for each of the cloudera services
##################################################################################

# Version Levels used
#	Windows 7
#	Docker 1.7.0
#	CentOS 6.6 (Docker image from Centos Repos 6.6)
#	Cloudera 5.4.3
#	
#	Ports Required
#	Clouder Manager Server 	:	7180
#	Zookeeper				:	2181
## Now lets setup Docker to be used as Name nodes(x 1) and Data nodes (x 2), Intitally we will try to setup with 3 containers.

# Lets install java - This should be moved to base image code
cd /media/sf_dockerRepos/dockerTmp
curl -LO 'http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jdk-8u45-linux-x64.rpm' -H 'Cookie: oraclelicense=accept-securebackup-cookie' && yum install jdk-8u45-linux-x64.rpm

# Install the cloudera Repository - link for CM5 - choose the appropriate one for your version
# http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cm_vd.html#concept_mb3_sfz_3q_unique_1
#( just in case you are using the manuall installation this will help)

curl -O http://archive.cloudera.com/cdh5/one-click-install/redhat/6/x86_64/cloudera-cdh-5-0.x86_64.rpm && yum -y --nogpgcheck localinstall cloudera-cdh-5-0.x86_64.rpm

cd /etc/yum.repos.d/
curl -O http://archive.cloudera.com/cm5/redhat/6/x86_64/cm/cloudera-manager.repo

# My caches are relatively new, wouldnt' want to do this on a slow speed network.
# yum -y clean all

# ssh-copy-id -i ~/.ssh/id_rsa.pub hadoop@hadoop-master

# This node will host the following components
# Namenode
# Resource Manager Host
# The DB to store configs - MySQL

yum -y install hadoop-yarn-resourcemanager \
hadoop-hdfs-namenode \
hadoop-mapreduce-historyserver \
hadoop-yarn-proxyserver

