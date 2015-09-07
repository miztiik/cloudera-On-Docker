#!/bin/bash
# set -x
##################################################################################
##	Author 			:	Miztiik
##	Version			:	0.1
##	Date   			:	07Sep2015
##
##	DESCRIPTION		:	Script to configure 4 node hadoop cluster
##
##	Ref[1]			:	http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cdh_ig_cdh5_install.html
##	Ref[2]			:	http://crazyadmins.com/install-multinode-cloudera-hadoop-cluster-cdh5-4-0-manually/
##	Ref[3]			:	http://www.cloudera.com/content/cloudera/en/documentation/cdh5/v5-1-x/CDH5-Installation-Guide/cdh5ig_hdfs_cluster_deploy.html?scroll=topic_11_2_1_unique_1
##
##################################################################################


# Name Node: http://master.backtobazics.com:50070/
# YARN Services: http://master.backtobazics.com:8088/
# Secondary Name Node: http://master.backtobazics.com:50090/
# Data Node 1: http://master.backtobazics.com:50075/
# Data Node 2: http://slave1.backtobazics.com:50075/

# ###### Ports for namenode1
#      namenode1        |     External	     |        Internal     |
# ----------------------|----------------------|---------------------|
# Namenode              |      8020            |                     |
# Namenode              |      50070           |                     |
# JobHistory Server     |      19888           |                     |
# JobHistory Server     |                      |          10020      |
# JobHistory Server     |                      |          10033      |
# ZooKeeper             |      2181            |                     |
# 
# ###### Ports for datanode1
#     datanode1         |     External         |        Internal     |
# ----------------------|----------------------|---------------------|
# Datanode              |      50010           |                     |
# Datanode              |      50020           |                     |
# Datanode              |      50090           |                     |
# Datanode              |      50075           |                     |
# Hue                   |      8888            |                     |
# 
# ###### Ports for datanode2
#      datanode2        |     External	     |        Internal     |
# ----------------------|----------------------|---------------------|
# Datanode              |      50010           |                     |
# Datanode              |      50020           |                     |
# Datanode              |      50090           |                     |
# Datanode              |      50075           |                     |
# ResourceManager       |      8030            |                     |
# ResourceManager       |      8031            |                     |
# ResourceManager       |      8032            |                     |
# ResourceManager       |      8033            |                     |
# ResourceManager       |      8888            |                     |
# 
# ###### Ports for datanode3
#      datanode2        |     External	     |        Internal     |
# ----------------------|----------------------|---------------------|
# Datanode              |      50010           |                     |
# Datanode              |      50020           |                     |
# Datanode              |      50090           |                     |
# Datanode              |      50075           |                     |


# Create a array to hold the hostnames where the clusters are going to be configured
# In future this can be picked up dynamically - Poorman's Cloudera Manager Server :)
declare -a clusterNodeHostNames=("namenode1" "datanode1" "datanode2" "datanode3")


#################################################
	#               ROLE ASSIGNMENTS                #
#################################################
#	
#	NAMENODE1	:	NAMENODE, ZOOKEEPER, HISTORY SERVER
#	DATANODE1	:	DATANODE, SECONDARAY NAMENODE, HUE
#	DATANODE2	:	DATANODE, YARN-NODE-MANAGER, RESOURCE MANAGER
#	DATANODE3	:	DATANODE, HIVE
#
#################################################

# An associative array to hold the roles information
declare -A roleAssignments
roleAssignments["NN"]="namenode1"
roleAssignments["HistoryServer"]="namenode1"
roleAssignments["ZooKeeper"]="namenode1"

roleAssignments["SNN"]="datanode1"
roleAssignments["DN"]="datanode1"
roleAssignments["Hue"]="datanode1"

roleAssignments["DN"]="datanode2"
roleAssignments["YarnNodeManager"]="datanode2"
roleAssignments["ResourceManager"]="datanode2"

roleAssignments["DN"]="datanode3"
roleAssignments["Hive"]="datanode3"

# Check if a value exists in an array
# @param $1 mixed  Needle  
# @param $2 array  Haystack
# @return  Success (0) if value exists, Failure (1) otherwise
# Usage: in_array "$needle" "${haystack[@]}"
# See: http://fvue.nl/wiki/Bash:_Check_if_array_element_exists

in_array() {
    local hay needle=$1
    shift
    for hay; do
        [[ "$hay" == "$needle" ]] && return 0
    done
    return 1
}

in_array "$(hostname -s)" "${clusterNodeHostNames[@]}" || { printf "\n\n\t You are on the wrong node - "$(hostname -s)"\n\n"; exit;}


function configureNameNode() {
# Enable debugging
set -x
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
sudo -u hdfs hadoop fs -chmod 775 /user

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

}

function configureDataNode1() {
# Enable debugging
set -x
[[ "$(hostname -s)" = "datanode1" ]] && { printf "\n\n\t Procceding with configuring the "$(hostname -s)" ...\n\n"; } || { printf "\n\n\t You are on the wrong node - "$(hostname -s)"\n\n"; exit;}

#################################################
#             DATANODE1 Installation            #
#################################################

####	Install DATANODE	####
yum -y install hadoop-hdfs-datanode hadoop-mapreduce
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
for x in `cd /etc/init.d ; ls hadoop-*` ; do sudo service $x status ; done

# To configure local storage directories for use by YARN on the datanodes
mkdir -p /data/1/yarn/local
mkdir -p /data/1/yarn/logs
chown -R yarn:yarn /data/1/yarn/local
chown -R yarn:yarn /data/1/yarn/logs
chmod 755 /data/1/yarn/local /data/1/yarn/logs

# Configure the Hadoop Daemons to Start at Boot Time
chkconfig hadoop-hdfs-datanode on
chkconfig hadoop-hdfs-secondarynamenode on

exit
##################################################
#               END OF CONFIGURATION             #
##################################################
	}

function configureDataNode2() {
# Enable debugging
set -x
[[ "$(hostname -s)" = "datanode2" ]] && { printf "\n\n\t Procceding with configuring the "$(hostname -s)" ...\n\n"; } || { printf "\n\n\t You are on the wrong node - "$(hostname -s)"\n\n"; exit;}


#################################################
#             DATANODE2 Installation            #
#################################################

####	Install DATANODE	####
sudo yum -y install hadoop-hdfs-datanode hadoop-mapreduce hadoop-yarn-nodemanager
yum -y install hadoop-hdfs hadoop-client hadoop-yarn

# Install RESOURCE MANAGER
yum -y install hadoop-yarn-resourcemanager

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
for x in `cd /etc/init.d ; ls hadoop-yarn-*` ; do sudo service $x start ; done

for x in `cd /etc/init.d ; ls hadoop-*` ; do sudo service $x status ; done

# To configure local storage directories for use by YARN on the datanodes
mkdir -p /data/1/yarn/local
mkdir -p /data/1/yarn/logs
chown -R yarn:yarn /data/1/yarn/local
chown -R yarn:yarn /data/1/yarn/logs
chmod 755 /data/1/yarn/local /data/1/yarn/logs

# Start YARN and the MapReduce JobHistory Server
# On the ResourceManager system - DATANODE2
service hadoop-yarn-resourcemanager start

# On each NodeManager system (typically the same ones where DataNode service runs) - DATANODE1 DATANODE2 DATANODE3
service hadoop-yarn-nodemanager start

# Configure the Hadoop Daemons to Start at Boot Time
chkconfig hadoop-hdfs-datanode on
chkconfig hadoop-yarn-nodemanager on
chkconfig hadoop-yarn-resourcemanager on

exit
##################################################
#               END OF CONFIGURATION             #
##################################################

	}
	
function configureDataNode3() {
# Enable debugging
set -x

[[ "$(hostname -s)" = "datanode3" ]] && { printf "\n\n\t Procceding with configuring the "$(hostname -s)" ...\n\n"; } || { printf "\n\n\t You are on the wrong node - "$(hostname -s)"\n\n"; exit;}

#################################################
#             DATANODE3 Installation            #
#################################################

####	Install DATANODE	####
yum -y install hadoop-hdfs-datanode hadoop-mapreduce
yum -y install hadoop-hdfs hadoop-client hadoop-yarn

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
for x in `cd /etc/init.d ; ls hadoop-mapreduce-*` ; do sudo service $x start ; done
for x in `cd /etc/init.d ; ls hadoop-yarn-*` ; do sudo service $x start ; done

for x in `cd /etc/init.d ; ls hadoop-*` ; do sudo service $x status ; done

# To configure local storage directories for use by YARN on the datanodes
mkdir -p /data/1/yarn/local
mkdir -p /data/1/yarn/logs
chown -R yarn:yarn /data/1/yarn/local
chown -R yarn:yarn /data/1/yarn/logs
chmod 755 /data/1/yarn/local /data/1/yarn/logs

# Configure the Hadoop Daemons to Start at Boot Time
chkconfig hadoop-hdfs-datanode on

exit

##################################################
#               END OF CONFIGURATION             #
##################################################
	}

function distributeClusterConf() {
	echo ""
	}
	
# Choose what to run where
if [ "$(hostname -s)" = "namenode1" ]; then
		configureNameNode
		elif [ "$(hostname -s)" = "datanode1" ]; then
		configureDataNode1
		elif [ "$(hostname -s)" = "datanode2" ]; then
		configureDataNode2
		elif [ "$(hostname -s)" = "datanode3" ]; then
		configureDataNode3
fi
	