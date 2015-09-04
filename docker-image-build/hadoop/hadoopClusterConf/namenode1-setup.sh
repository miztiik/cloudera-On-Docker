#!/bin/bash
# set -x
##################################################################################
##	Author 			:	Miztiik
##	Version			:	0.2
##	Date   			:	04Sep2015
##
##	DESCRIPTION		:	NAMENODE1 - Script to configure hadoop cluster - Should be using salt/chef in future
##
##	Ref[1]			:	http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cdh_ig_cdh5_install.html
##	Ref[2]			:	http://crazyadmins.com/install-multinode-cloudera-hadoop-cluster-cdh5-4-0-manually/
##	Ref[3]			:	http://www.cloudera.com/content/cloudera/en/documentation/cdh5/v5-1-x/CDH5-Installation-Guide/cdh5ig_hdfs_cluster_deploy.html?scroll=topic_11_2_1_unique_1
##
##################################################################################


#################################################
#				ROLE ASSIGNMENTS				#
#################################################
#	
#	NAMENODE1	:	NAMENODE, ZOOKEEPER, HISTORY SERVER
#	DATANODE1	:	DATANODE, SECONDARAY NAMENODE, HUE
#	DATANODE2	:	DATANODE, RESOURCE MANAGER, HIVE
#	DATANODE3	:	DATANODE,
#
#################################################

# Expose the relevant ports
# HDFS		:	8020 50010 50020 50070 50075 50090
# Mapred	:	19888
# Yarn		:	8030 8031 8032 8033 8040 8042 8088
# Other		:	49707 2122
# ClouderaMgr:	7182

[[ "$(hostname -s)" = "namenode1" ]] && { printf "\n\n\t Procceding with configuring the "$(hostname -s)" ...\n\n"; } || { printf "\n\n\t You are on the wrong node - "$(hostname -s)"\n\n"; exit;}

#################################################
#			NAMENODE Installation				#
#################################################

####	Install namenode	####
yum -y install hadoop-hdfs-namenode
yum -y install hadoop-hdfs hadoop-client hadoop-yarn

####	Zookeeper Installation	####

# Install and deploy ZooKeeper.
yum -y install zookeeper-server

# Create zookeeper dir and apply permissions
mkdir -p /var/lib/zookeeper
chown -R zookeeper /var/lib/zookeeper/

# Init zookeeper and start the service
service zookeeper-server init
service zookeeper-server start

#### Install HISTORY / Proxy SERVER	####
yum -y install hadoop-mapreduce-historyserver hadoop-yarn-proxyserver

#########################################################################
#				CONFIGURING THE CLUSTER - "NCLUSTER"					#
#########################################################################

#########################################
#				namdenode1				#
#########################################
# Copying the Hadoop Configuration and Setting Alternatives
# "ncluster" being the name of my cluster
# "\cp" temporarily unalias the bash profile version of cp
# Ref[1] - http://stackoverflow.com/questions/8488253/how-to-force-cp-to-overwrite-without-confirmation
rm -rf /etc/hadoop/conf.ncluster
cp -r /etc/hadoop/conf.empty /etc/hadoop/conf.ncluster
\cp -rf /media/sf_dockerRepos/cloudera-On-Docker/docker-image-build/hadoop/hadoopClusterConf/conf.ncluster/* /etc/hadoop/conf.ncluster/

# CDH uses the alternatives setting to determine which Hadoop configuration to use. Set alternatives to point to your custom directory
# To display the current setting
# alternatives --display hadoop-conf
alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.ncluster 50
alternatives --set hadoop-conf /etc/hadoop/conf.ncluster

# Hadoop expects the permissions to be correct
mkdir -p /opt/hadoop/hadoop/dfs/name
chown -R hdfs:hdfs /opt/hadoop/hadoop/dfs/name
chmod 700 /opt/hadoop/hadoop/dfs/name
chmod go-rx /opt/hadoop/hadoop/dfs/name

exit

