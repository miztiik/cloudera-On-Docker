#!/bin/bash
set -x
##################################################################################
## Cloudera Manager Node Start Script
##
## VERSION		:0.0.2
## DATE			:28Aug2015
##################################################################################


# Probably will use them in the future
DOCKER_IMAGE_NAME="local/hadoop_cloudera_mgr_base:v1"
DOCKER_CONTAINERS_NAME="clouderamgrnode"             
DOCKER_CONTAINERS_HOSTNAME="clouderamgrnode"         

# start conteiner if "docker some_image run" earlier
found_container=$(docker ps -a | grep "$DOCKER_CONTAINERS_NAME")
if [ ! -n "$found_container" ]; then
	
	# Cloudera recommends swappiness to zero (throws error - moving to start up scripts)
	# https://github.com/docker/docker/issues/5703
	# https://github.com/docker/docker/issues/4717
	sysctl vm.swappiness=0
	
	# Lets start the DB first followed by the manager server
	service cloudera-scm-server-db start
	sleep 30
	service cloudera-scm-server start
	
	# RUN /etc/init.d/cloudera-scm-agent start

	else
		printf "\n\n\t\t The container $DOCKER_CONTAINERS_NAME is not running!!!\n\n"
fi


# yum -y install cloudera-manager-agent
# yum -y install cloudera-manager-daemons
# yum list installed bigtop-utils
# yum list installed bigtop-jsvc
# yum -y install bigtop-tomcat
# yum -y install hadoop-kms
# yum -y install hadoop-httpfs
# yum -y install hadoop-hdfs-nfs3
# yum -y install hadoop-hdfs-fuse
# yum -y install hbase