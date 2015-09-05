#!/bin/bash
# set -x
##################################################################################
##	Author 			:	Miztiik
##	Version			:	0.2
##	Date   			:	04Sep2015
##
##	DESCRIPTION		:	DATANODE1 - Script to configure hadoop cluster - Should be using salt/chef in future
##
##	Ref[1]			:	http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cdh_ig_cdh5_install.html
##	Ref[2]			:	http://crazyadmins.com/install-multinode-cloudera-hadoop-cluster-cdh5-4-0-manually/
##	Ref[3]			:	http://www.cloudera.com/content/cloudera/en/documentation/cdh5/v5-1-x/CDH5-Installation-Guide/cdh5ig_hdfs_cluster_deploy.html?scroll=topic_11_2_1_unique_1
##
##################################################################################


#################################################
#               ROLE ASSIGNMENTS                #
#################################################
#	
#	NAMENODE1	:	NAMENODE, ZOOKEEPER, HISTORY SERVER
#	DATANODE1	:	DATANODE, YARN-NODE-MANAGER, SECONDARAY NAMENODE, HUE
#	DATANODE2	:	DATANODE, YARN-NODE-MANAGER,  RESOURCE MANAGER, HIVE
#	DATANODE3	:	DATANODE, YARN-NODE-MANAGER, 
#
#################################################

# Expose the relevant ports
# HDFS			:	8020 50010 50020 50070 50075 50090
# Mapred		:	19888
# Yarn			:	8030 8031 8032 8033 8040 8042 8088
# Other			:	49707 2122
# ClouderaMgr	:	7182

[[ "$(hostname -s)" = "datanode1" ]] && { printf "\n\n\t Procceding with configuring the "$(hostname -s)" ...\n\n"; } || { printf "\n\n\t You are on the wrong node - "$(hostname -s)"\n\n"; exit;}

#################################################
#             DATANODE1 Installation            #
#################################################

####	Install DATANODE	####
yum -y install hadoop-hdfs-datanode hadoop-mapreduce hadoop-yarn-nodemanager
yum -y install hadoop-hdfs hadoop-client hadoop-yarn

# Install secondary namenode
yum -y install hadoop-hdfs-secondarynamenode

#########################################################################
#               CONFIGURING THE CLUSTER - "NCLUSTER"                    #
#########################################################################

#Create local directories for hadoop to storte data
mkdir -p /data/1/dfs/dn
chown -R hdfs:hdfs /data/1/dfs/dn
chmod 700 /data/1/dfs/dn

# Copy the cluster configs
rm -rf /etc/hadoop/conf.ncluster
scp -rp -i /home/hadoopadmin/.ssh/id_rsa hadoopadmin@namenode1:/etc/hadoop/conf.ncluster /etc/hadoop/conf.ncluster

# Set the alternatives
alternatives --verbose --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.ncluster 50
alternatives --set hadoop-conf /etc/hadoop/conf.ncluster

# To start the HDFS on each node
for x in `cd /etc/init.d ; ls hadoop-hdfs-*` ; do sudo service $x start ; done
for x in `cd /etc/init.d ; ls hadoop-hdfs-*` ; do sudo service $x status ; done

# To configure local storage directories for use by YARN on the datanodes
mkdir -p /data/1/yarn/local
mkdir -p /data/1/yarn/logs
chown -R yarn:yarn /data/1/yarn/local
chown -R yarn:yarn /data/1/yarn/logs
chmod 755 /data/1/yarn/local /data/1/yarn/logs

# On each NodeManager system (typically the same ones where DataNode service runs) - DATANODE1 DATANODE2 DATANODE3
service hadoop-yarn-nodemanager start

# Configure the Hadoop Daemons to Start at Boot Time
chkconfig hadoop-hdfs-datanode on
chkconfig hadoop-yarn-nodemanager on
chkconfig hadoop-hdfs-secondarynamenode on

exit
##################################################
#               END OF CONFIGURATION             #
##################################################