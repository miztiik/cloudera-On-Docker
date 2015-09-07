#!/bin/bash
# set -x
##################################################################################
##	Author 			:	Miztiik
##	Version			:	0.3
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
#               ROLE ASSIGNMENTS                #
#################################################
#	
#	NAMENODE1	:	NAMENODE, ZOOKEEPER, HISTORY SERVER
#	DATANODE1	:	DATANODE, YARN-NODE-MANAGER, SECONDARAY NAMENODE, HUE
#	DATANODE2	:	DATANODE, YARN-NODE-MANAGER, RESOURCE MANAGER, HIVE
#	DATANODE3	:	DATANODE, YARN-NODE-MANAGER, 
#
#################################################

[[ "$(hostname -s)" = "namenode1" ]] && { printf "\n\n\t Procceding with configuring the "$(hostname -s)" ...\n\n"; } || { printf "\n\n\t You are on the wrong node - "$(hostname -s)"\n\n"; exit;}

#################################################
#             NAMENODE1 Installation            #
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
#               CONFIGURING THE CLUSTER - "NCLUSTER"                    #
#########################################################################

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

#Create local directories for hadoop to storte data
# Hadoop expects the permissions to be correct
mkdir -p /data/1/dfs/nn
chown -R hdfs:hdfs /data/1/dfs/nn
chmod 700 /data/1/dfs/nn
chmod go-rx /data/1/dfs/nn

# Format the namenode
sudo -u hdfs hdfs namenode -format

# To start the HDFS on each node
for x in `cd /etc/init.d ; ls hadoop-hdfs-*` ; do sudo service $x start ; done
for x in `cd /etc/init.d ; ls hadoop-hdfs-*` ; do sudo service $x status ; done

# Hadoop needs a tmp directory with the right permissions (from any of the nodes, I do it from the namenode)
sudo -u hdfs hadoop fs -mkdir /tmp
sudo -u hdfs hadoop fs -chmod -R 1777 /tmp

# Create history directories and set permissions
sudo -u hdfs hadoop fs -mkdir -p /user/history
sudo -u hdfs hadoop fs -chmod -R 1777 /user/history
sudo -u hdfs hadoop fs -chown mapred:hadoop /user/history

# Create Yarn log directories and set permissions
sudo -u hdfs hadoop fs -mkdir -p /var/log/hadoop-yarn
sudo -u hdfs hadoop fs -chown yarn:mapred /var/log/hadoop-yarn

# Verify the HDFS File Structure
sudo -u hdfs hadoop fs -ls -R /

# To start the MapReduce JobHistory Server - NAMENODE1
service hadoop-mapreduce-historyserver start
service hadoop-mapreduce-historyserver status

# Create user for running mapreduce jobs - "huser"
sudo -u hdfs hadoop fs -mkdir /user/huser
sudo -u hdfs hadoop fs -chown huser /user/huser

# Configure the Hadoop Daemons to Start at Boot Time
chkconfig hadoop-hdfs-namenode on
chkconfig hadoop-mapreduce-historyserver on
chkconfig zookeeper-server on

exit

##################################################
#               END OF CONFIGURATION             #
##################################################

