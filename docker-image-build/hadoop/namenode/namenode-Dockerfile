##################################################################################
## Namenode setup docker file
##
## VERSION		:0.0.3
## DATE			:24Jul2015
##
##
## Ref [1]	:	https://registry.hub.docker.com/u/sequenceiq/hadoop-docker/dockerfile/
## Ref [2]	:	https://github.com/ambling/hadoop-docker/blob/master/namenode/Dockerfile
## Ref [3]	:	
##
##################################################################################

FROM mystique/cloudera-on-docker:latest
MAINTAINER mystique <miztiik@gmail.com>

# Setup yum to use caching in the shared folder to allow it to be reused by multiple systems, number of copies to 3
RUN yum clean all && yum install -y hadoop-hdfs-namenode

# config hadoop
# you have to configure hostname and ssh public keys first
RUN cp -r /tmp/conf.cluster /etc/hadoop/
RUN alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.cluster 50 
RUN alternatives --set hadoop-conf /etc/hadoop/conf.cluster

# change user 
USER hdfs

# make necessary directories
RUN mkdir -p /var/lib/hadoop-hdfs/cache/hdfs/dfs/name
# RUN chown -R hdfs:hadoop /var/lib/hadoop-hdfs/cache/hdfs
RUN chmod -R 700 /var/lib/hadoop-hdfs/cache/hdfs/dfs

# format the hdfs
RUN hdfs namenode -format

# ports for namenode (deprecated, use -p in docker run command, see startup.sh)
# fs.default.name/fs.defaultFS TCP
EXPOSE 8020	
# dfs.http.address/dfs.namenode.http-address TCP
EXPOSE 50070	
# dfs.https.address/dfs.namenode.https-address TCP
EXPOSE 50470	

# change user back to boot
USER root

# config supervisor
RUN mv /tmp/supervisord.conf /etc/

# clean up
RUN rm -rf /tmp/*
