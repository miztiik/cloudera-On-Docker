#!/bin/bash
set -x
##################################################################################
##	Author 		:	Miztiik
##	Version		:	0.1
##	Date   		:	27Jul2015
##	Assumptions	:	Script to configure hadoop cluster - Should be using salt/chef in future
##	Ref[1]		:	http://www.cloudera.com/content/cloudera/en/documentation/cdh5/v5-1-x/CDH5-Installation-Guide/cdh5ig_hdfs_cluster_deploy.html?scroll=topic_11_2_1_unique_1
##################################################################################

# Get user confirmation that we are running from Namenode
read -p "You should be running this from namenode, Do you want to proceed? -  " -n 1 -r
if [[ !$REPLY =~ ^[Yy]$ ]]
then
    { printf "\n\n\t Exitting!!\n\n"; exit; }
fi

printf "\n\n\tStarting to setup the configurations...Please wait"

#########################################
#				namdenode1				#
#########################################
# Copying the Hadoop Configuration and Setting Alternatives
# "ncluster" being the name of my cluster
cp -r /etc/hadoop/conf.empty /etc/hadoop/conf.ncluster

# CDH uses the alternatives setting to determine which Hadoop configuration to use. Set alternatives to point to your custom directory
alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.ncluster 50
alternatives --set hadoop-conf /etc/hadoop/conf.ncluster

# To display the current setting
# alternatives --display hadoop-conf

# On the namenode
ssh namenode1
mkdir -p /opt/hadoop/hadoop/dfs/name
chown -R hdfs:hdfs /opt/hadoop/hadoop/dfs/name
chmod 700 /opt/hadoop/hadoop/dfs/name
chmod go-rx /opt/hadoop/hadoop/dfs/name
exit

sudo -u hdfs hadoop fs -mkdir /tmp
$ sudo -u hdfs hadoop fs -chmod -R 1777 /tmp

# On the datanodes, create the directories to store data
#########################################
#				datanode1				#
#########################################
ssh datanode1
mkdir -p /opt/hadoop/hadoop/dfs/name/data
chown -R hdfs:hdfs /opt/hadoop/hadoop/dfs/name/data
chmod 700 /opt/hadoop/hadoop/dfs/name/data

# Copy the cluster configs
scp -r hadoopadmin@namenode1:/etc/hadoop/conf.ncluster /etc/hadoop/conf.ncluster

# Set the alternatives
alternatives --verbose --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.ncluster 50
alternatives --set hadoop-conf /etc/hadoop/conf.ncluster
exit
#########################################
#				datanode2				#
#########################################
ssh datanode2
mkdir -p /opt/hadoop/hadoop/dfs/name/data
chown -R hdfs:hdfs /opt/hadoop/hadoop/dfs/name/data
chmod 700 /opt/hadoop/hadoop/dfs/name/data

# Copy the cluster configs
scp -r hadoopadmin@namenode1:/etc/hadoop/conf.ncluster /etc/hadoop/conf.ncluster

# Set the alternatives
alternatives --verbose --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.ncluster 50
alternatives --set hadoop-conf /etc/hadoop/conf.ncluster
exit

# Formatting the namenode
ssh namenode1
sudo -u hdfs hdfs namenode -format
exit

# To start the HDFS on each node
for x in `cd /etc/init.d ; ls hadoop-hdfs-*` ; do sudo service $x start ; done






