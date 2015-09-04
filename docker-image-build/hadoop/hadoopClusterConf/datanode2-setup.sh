#!/bin/bash
# set -x
##################################################################################
##	Author 			:	Miztiik
##	Version			:	0.2
##	Date   			:	04Sep2015
##
##	DESCRIPTION		:	NAMENODE2 - Script to configure hadoop cluster - Should be using salt/chef in future
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

[[ "$(hostname -s)" = "datanode2" ]] && { printf "\n\n\t Procceding with configuring the "$(hostname -s)" ...\n\n"; } || { printf "\n\n\t You are on the wrong node - "$(hostname -s)"\n\n"; exit;}


#################################################
#			DATANODE2 Installation				#
#################################################

####	Install DATANODE	####
sudo yum -y install hadoop-hdfs-datanode hadoop-mapreduce hadoop-yarn-nodemanager
yum -y install hadoop-hdfs hadoop-client hadoop-yarn

# Install RESOURCE MANAGER
yum -y install hadoop-yarn-resourcemanager

#########################################################################
#				CONFIGURING THE CLUSTER - "NCLUSTER"					#
#########################################################################

#########################################
#				datanode2				#
#########################################
mkdir -p /opt/hadoop/hadoop/dfs/name/data
chown -R hdfs:hdfs /opt/hadoop/hadoop/dfs/name/data
chmod 700 /opt/hadoop/hadoop/dfs/name/data

# Copy the cluster configs
scp -rp -i /home/hadoopadmin/.ssh/id_rsa hadoopadmin@namenode1:/etc/hadoop/conf.ncluster /etc/hadoop/conf.ncluster

# Set the alternatives
alternatives --verbose --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.ncluster 50
alternatives --set hadoop-conf /etc/hadoop/conf.ncluster

exit
