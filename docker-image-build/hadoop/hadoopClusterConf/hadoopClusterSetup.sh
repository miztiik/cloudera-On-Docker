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

# Get user confirmation that we are running from Namenode
read -p "You should be running this from namenode, Do you want to proceed? - " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
    { printf "\n\n\tStarting to setup the configurations...Please wait"; }
else
	{ printf "\\n\n\t You chose to exit"\n\n; exit; }
fi

ssh -i /home/hadoopadmin/.ssh/id_rsa hadoopadmin@datanode1 

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