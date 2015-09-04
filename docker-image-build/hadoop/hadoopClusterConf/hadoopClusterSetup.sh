#!/bin/bash
set -x
##################################################################################
##	Author 			:	Miztiik
##	Version			:	0.2
##	Date   			:	04Sep2015
##
##	DESCRIPTION		:	NAMENODE - Script to configure hadoop cluster - Should be using salt/chef in future
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


#################################################
#			NAMENODE Installation				#
#################################################

# Get user confirmation that we are running from Namenode
read -p "You should be running this from namenode, Do you want to proceed? - " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
    { printf "\n\n\tStarting to setup the configurations...Please wait"; }
else
	{ printf "\\n\n\t You chose to exit"\n\n; exit; }
fi

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


#################################################
#			DATANODE1 Installation				#
#################################################
su hadoopadmin
ssh hadoopadmin@datanode1 << "EOF"
sudo su
####	Install DATANODE	####
yum -y install hadoop-hdfs-datanode hadoop-mapreduce hadoop-yarn-nodemanager
yum -y install hadoop-hdfs hadoop-client hadoop-yarn

# Install secondary namenode
yum -y install hadoop-hdfs-secondarynamenode
exit
EOF
exit

#################################################
#			DATANODE2 Installation				#
#################################################
su hadoopadmin
ssh hadoopadmin@datanode2 << "EOF"
sudo su
####	Install DATANODE	####
yum -y install hadoop-hdfs-datanode hadoop-mapreduce hadoop-yarn-nodemanager
yum -y install hadoop-hdfs hadoop-client hadoop-yarn

# Install resource manager
yum -y install hadoop-yarn-resourcemanager
exit
EOF
exit

#################################################
#			DATANODE3 Installation				#
#################################################
su hadoopadmin
ssh hadoopadmin@datanode3 << "EOF"
sudo su
####	Install DATANODE	####
yum -y install hadoop-hdfs-datanode hadoop-mapreduce hadoop-yarn-nodemanager
yum -y install hadoop-hdfs hadoop-client hadoop-yarn
exit
EOF
exit

#########################################################################
#				CONFIGURING THE CLUSTER - "NCLUSTER"					#
#########################################################################

#########################################
#				namdenode1				#
#########################################
su hadoopadmin
sudo su
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
exit

# On the datanodes, create the directories to store data
#########################################
#				datanode1				#
#########################################
sudo su hadoopadmin
ssh datanode1
sudo su
mkdir -p /opt/hadoop/hadoop/dfs/name/data
chown -R hdfs:hdfs /opt/hadoop/hadoop/dfs/name/data
chmod 700 /opt/hadoop/hadoop/dfs/name/data

# Copy the cluster configs
scp -rp -i /home/hadoopadmin/.ssh/id_rsa hadoopadmin@namenode1:/etc/hadoop/conf.ncluster /etc/hadoop/conf.ncluster

# Set the alternatives
alternatives --verbose --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.ncluster 50
alternatives --set hadoop-conf /etc/hadoop/conf.ncluster

exit
exit

#########################################
#				datanode2				#
#########################################
sudo su hadoopadmin
ssh datanode2
sudo su
mkdir -p /opt/hadoop/hadoop/dfs/name/data
chown -R hdfs:hdfs /opt/hadoop/hadoop/dfs/name/data
chmod 700 /opt/hadoop/hadoop/dfs/name/data

# Copy the cluster configs
scp -rp -i /home/hadoopadmin/.ssh/id_rsa hadoopadmin@namenode1:/etc/hadoop/conf.ncluster /etc/hadoop/conf.ncluster

# Set the alternatives
alternatives --verbose --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.ncluster 50
alternatives --set hadoop-conf /etc/hadoop/conf.ncluster

exit
exit

#########################################
#				datanode3				#
#########################################
sudo su hadoopadmin
ssh datanode2
sudo su
mkdir -p /opt/hadoop/hadoop/dfs/name/data
chown -R hdfs:hdfs /opt/hadoop/hadoop/dfs/name/data
chmod 700 /opt/hadoop/hadoop/dfs/name/data

# Copy the cluster configs
scp -rp -i /home/hadoopadmin/.ssh/id_rsa hadoopadmin@namenode1:/etc/hadoop/conf.ncluster /etc/hadoop/conf.ncluster

# Set the alternatives
alternatives --verbose --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.ncluster 50
alternatives --set hadoop-conf /etc/hadoop/conf.ncluster

exit
exit

# Format the namenode
sudo -u hdfs hdfs namenode -format


# To start the HDFS on each node
for x in `cd /etc/init.d ; ls hadoop-hdfs-*` ; do sudo service $x start ; done

# Hadoop needs a tmp directory with the right permissions
sudo -u hdfs hadoop fs -mkdir /tmp
sudo -u hdfs hadoop fs -chmod -R 1777 /tmp

##################################################
#				END OF INSTALLATION				 #
##################################################