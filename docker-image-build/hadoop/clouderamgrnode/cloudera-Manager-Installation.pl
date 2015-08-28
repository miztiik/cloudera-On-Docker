##!/usr/bin/perl
##################################################################################
##	Author 		: Miztiik
##	Date   		: 18Jul2015
##	Version		: 0.2
##	Assumptions	: BaseOS Image - Centos 6.6(max supported by Cloudera 5.x)
##				: My idea is to create seperate images/containers for each of the cloudera services
##################################################################################

# Cloudera Manager Node Installation

# Installing Cloudera repositories
# http://www.cloudera.com/content/cloudera/en/documentation/cdh5/v5-0-0/CDH5-Installation-Guide/cdh5ig_cdh5_install.html#topic_4_4_1_unique_1

# Attempting cloudera manager managed installation
cd /media/sf_dockerRepos/RPMs/
curl -O  http://archive.cloudera.com/cm5/installer/latest/cloudera-manager-installer.bin
chmod u+x cloudera-manager-installer.bin
/media/sf_dockerRepos/RPMs/cloudera-manager-installer.bin


# Install Oracle
yum -y install oracle-j2sdk1.7

# Cloudera Manager Server Packages
yum -y install cloudera-manager-daemons cloudera-manager-server

# Installing and Starting the Cloudera Manager Server Embedded Database
yum -y install cloudera-manager-server-db-2
service cloudera-scm-server-db start

# ####################################################################
# Installing CD5 Manually
# The "hadoop-yarn" and "hadoop-hdfs" packages are installed on each system automatically as dependencies of the other packages.
	
# PREREQ 
# INSTALL - ZOOKEEPER
# http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cdh_ig_zookeeper_package_install.html
yum -y install zookeeper

mkdir -p /var/lib/zookeeper
chown -R zookeeper /var/lib/zookeeper/

service zookeeper-server init
service zookeeper-server start

# INSTALL - Resource Manager host
yum -y install hadoop-yarn-resourcemanager

# INSTALL - NameNode host
yum -y install hadoop-hdfs-namenode

# INSTALL - Secondary NameNode host (if used)
yum -y hadoop-hdfs-secondarynamenode

# INSTALL - All cluster hosts except the Resource Manager
yum -y install hadoop-yarn-nodemanager hadoop-hdfs-datanode hadoop-mapreduce


# INSTALL - Proxy (preferably secondary namenode)
yum -y install hadoop-mapreduce-historyserver hadoop-yarn-proxyserver

# INSTALL - All clients
yum -y install hadoop-client


# Installing resource manager
yum clean all
yum -y install hadoop-yarn-resourcemanager

yum install --downloadonly hadoop-yarn-resourcemanager


=============================


[N1Repo]
name=N1Repo
baseurl=http://localhost/repo
enabled=1
gpgcheck=0


host -t PTR 172.17.0.6 
wget -qO- -T 1 -t 1 http://169.254.169.254/latest/meta-data/public-hostname && /bin/echo

yum makecache
yum list installed jdk 
yum list installed oracle-j2sdk1.7
yum list installed cloudera-manager-agent
yum list installed cloudera-manager-daemons  

yum -y install jdk.x86_64
yum -y install oracle-j2sdk1.7.x86_64 
yum -y install cloudera-manager-agent
yum -y install cloudera-manager-daemons


Configuring Cloudera Manager Agent...
BEGIN grep server_host=172.17.0.6 /etc/cloudera-scm-agent/config.ini 
END (1) 
BEGIN sed -e 's/\(server_host=\).*/\1172.17.0.6/' -i /etc/cloudera-scm-agent/config.ini 
END (0) 
scm agent configured

Hostname is invalid; it contains an underscore character

/tmp/scm_prepare_node.8eL2zb6G 
using SSH_CLIENT to get the SCM hostname: 172.17.0.6 49072 22 
opening logging file descriptor 
Starting installation script...
Acquiring installation lock...
BEGIN flock 4 
END (0) 
Detecting root privileges...
effective UID is 0 
Detecting distribution...
BEGIN grep Tikanga /etc/redhat-release 
END (1) 
BEGIN grep 'CentOS release 5' /etc/redhat-release 
END (1) 
BEGIN grep 'Scientific Linux release 5' /etc/redhat-release 
END (1) 
BEGIN grep Santiago /etc/redhat-release 
END (1) 
BEGIN grep 'CentOS Linux release 6' /etc/redhat-release 
END (1) 
BEGIN grep 'CentOS release 6' /etc/redhat-release 
END (0) 
/etc/redhat-release ==> CentOS 6 
Detecting Cloudera Manager Server...
CentOS release 6.6 (Final) 
BEGIN host -t PTR 172.17.0.6 
Host 6.0.17.172.in-addr.arpa. not found: 3(NXDOMAIN) 
END (1) 
BEGIN which python 
/usr/bin/python 
END (0) 
BEGIN python -c 'import socket; import sys; s = socket.socket(socket.AF_INET); s.settimeout(5.0); s.connect((sys.argv[1], int(sys.argv[2]))); s.close();' 172.17.0.6 7182 
END (0) 
BEGIN which wget 
END (1) 
which: no wget in (/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin) 
BEGIN wget -qO- -T 1 -t 1 http://169.254.169.254/latest/meta-data/public-hostname && /bin/echo 
END (127) 
/tmp/scm_prepare_node.8eL2zb6G/scm_prepare_node.sh: line 105: wget: command not found 
Installing package repositories...
validating format of repository file /tmp/scm_prepare_node.8eL2zb6G/repos/rhel6/cloudera-manager.repo 
installing repository file /tmp/scm_prepare_node.8eL2zb6G/repos/rhel6/cloudera-manager.repo 
repository file /tmp/scm_prepare_node.8eL2zb6G/repos/rhel6/cloudera-manager.repo installed 
Refreshing package metadata...
BEGIN yum clean all 
Loaded plugins: presto 
Cleaning repos: base cloudera-cdh5 cloudera-manager epel extras updates 
Cleaning up Everything 
0 delta-package files removed, by presto 
END (0) 
BEGIN rm -Rf /var/cache/yum/* 
END (0) 
BEGIN yum makecache 
Loaded plugins: presto 
Metadata Cache Created 
END (0) 
Installing jdk package...
BEGIN yum list installed jdk 
Loaded plugins: presto 
Error: No matching Packages to list 
END (1) 
BEGIN yum info jdk 
Loaded plugins: presto 
Available Packages 
Name : jdk 
Arch : x86_64 
Epoch : 2000 
Version : 1.6.0_31 
Release : fcs 
Size : 68 M 
Repo : cloudera-manager 
Summary : Java(TM) Platform Standard Edition Development Kit 
URL : http://java.sun.com/ 
License : Copyright (c) 2011, Oracle and/or its affiliates. All rights 
: reserved. Also under other license(s) as shown at the Description 
: field. 
Description : The Java Platform Standard Edition Development Kit (JDK) includes 
: both the runtime environment (Java virtual machine, the Java 
: platform classes and supporting files) and development tools 
: (compilers, debuggers, tool libraries and other tools). 
: 
: The JDK is a development environment for building applications, 
: applets and components that can be deployed with the Java Platform 
: Standard Edition Runtime Environment. 

END (0) 
BEGIN yum -y install jdk.x86_64 
Loaded plugins: presto 
Setting up Install Process 
Resolving Dependencies 
--> Running transaction check 
---> Package jdk.x86_64 2000:1.6.0_31-fcs will be installed 
--> Finished Dependency Resolution 

Dependencies Resolved 

================================================================================ 
Package Arch Version Repository Size 
================================================================================ 
Installing: 
jdk x86_64 2000:1.6.0_31-fcs cloudera-manager 68 M 

Transaction Summary 
================================================================================ 
Install 1 Package(s) 

Total download size: 68 M 
Installed size: 143 M 
Downloading Packages: 
Setting up and reading Presto delta metadata 
Processing delta metadata 
Package(s) data still to download: 68 M 
Running rpm_check_debug 
Running Transaction Test 
Transaction Test Succeeded 
Running Transaction 
Installing : 2000:jdk-1.6.0_31-fcs.x86_64 1/1 
warning: /etc/init.d/jexec saved as /etc/init.d/jexec.rpmorig 
Unpacking JAR files... 
rt.jar... 
jsse.jar... 
charsets.jar... 
tools.jar... 
localedata.jar... 
plugin.jar... 
javaws.jar... 
deploy.jar... 
Verifying : 2000:jdk-1.6.0_31-fcs.x86_64 1/1 

Installed: 
jdk.x86_64 2000:1.6.0_31-fcs 

Complete! 
END (0) 
remote package jdk installed 
Installing oracle-j2sdk1.7 package...
BEGIN yum list installed oracle-j2sdk1.7 
Loaded plugins: presto 
Installed Packages 
oracle-j2sdk1.7.x86_64 1.7.0+update67-1 @cloudera-manager 
END (0) 
BEGIN echo jdk oracle-j2sdk1.7 cloudera-manager-agent cloudera-manager-daemons | grep oracle-j2sdk1.7 
END (0) 
jdk oracle-j2sdk1.7 cloudera-manager-agent cloudera-manager-daemons 
BEGIN yum info oracle-j2sdk1.7 
Loaded plugins: presto 
Installed Packages 
Name : oracle-j2sdk1.7 
Arch : x86_64 
Version : 1.7.0+update67 
Release : 1 
Size : 279 M 
Repo : installed 
From repo : cloudera-manager 
Summary : no description given 
URL : http://example.com/no-uri-given 
License : unknown 
Description : no description given 

END (0) 
BEGIN yum -y install oracle-j2sdk1.7.x86_64 
Loaded plugins: presto 
Setting up Install Process 
Package oracle-j2sdk1.7-1.7.0+update67-1.x86_64 already installed and latest version 
Nothing to do 
END (0) 
remote package oracle-j2sdk1.7 installed 
Installing cloudera-manager-agent package...
BEGIN yum list installed cloudera-manager-agent 
Loaded plugins: presto 
Error: No matching Packages to list 
END (1) 
BEGIN yum info cloudera-manager-agent 
Loaded plugins: presto 
Available Packages 
Name : cloudera-manager-agent 
Arch : x86_64 
Version : 5.4.3 
Release : 1.cm543.p0.258.el6 
Size : 4.6 M 
Repo : cloudera-manager 
Summary : The Cloudera Manager Agent 
URL : http://www.cloudera.com 
License : Proprietary 
Description : The Cloudera Manager Agent. 
: 
: The Agent is deployed to machines running services managed by 
: Cloudera Manager. 

END (0) 
Version : 5.4.3 
Release : 1.cm543.p0.258.el6 
BEGIN yum -y install cloudera-manager-agent 
Loaded plugins: presto 
Setting up Install Process 
Resolving Dependencies 
--> Running transaction check 
---> Package cloudera-manager-agent.x86_64 0:5.4.3-1.cm543.p0.258.el6 will be installed 
--> Processing Dependency: cloudera-manager-daemons = 5.4.3 for package: cloudera-manager-agent-5.4.3-1.cm543.p0.258.el6.x86_64 
--> Processing Dependency: portmap for package: cloudera-manager-agent-5.4.3-1.cm543.p0.258.el6.x86_64 
--> Processing Dependency: fuse for package: cloudera-manager-agent-5.4.3-1.cm543.p0.258.el6.x86_64 
--> Processing Dependency: libxslt for package: cloudera-manager-agent-5.4.3-1.cm543.p0.258.el6.x86_64 
--> Processing Dependency: fuse-libs for package: cloudera-manager-agent-5.4.3-1.cm543.p0.258.el6.x86_64 
--> Processing Dependency: cyrus-sasl-gssapi for package: cloudera-manager-agent-5.4.3-1.cm543.p0.258.el6.x86_64 
--> Processing Dependency: cyrus-sasl-plain for package: cloudera-manager-agent-5.4.3-1.cm543.p0.258.el6.x86_64 
--> Running transaction check 
---> Package cloudera-manager-daemons.x86_64 0:5.4.3-1.cm543.p0.258.el6 will be installed 
---> Package cyrus-sasl-gssapi.x86_64 0:2.1.23-15.el6_6.2 will be installed 
--> Processing Dependency: cyrus-sasl-lib = 2.1.23-15.el6_6.2 for package: cyrus-sasl-gssapi-2.1.23-15.el6_6.2.x86_64 
---> Package cyrus-sasl-plain.x86_64 0:2.1.23-15.el6_6.2 will be installed 
---> Package fuse.x86_64 0:2.8.3-4.el6 will be installed 
--> Processing Dependency: kernel >= 2.6.14 for package: fuse-2.8.3-4.el6.x86_64 
---> Package fuse-libs.x86_64 0:2.8.3-4.el6 will be installed 
---> Package libxslt.x86_64 0:1.1.26-2.el6_3.1 will be installed 
---> Package rpcbind.x86_64 0:0.2.0-11.el6 will be installed 
--> Processing Dependency: libgssglue for package: rpcbind-0.2.0-11.el6.x86_64 
--> Processing Dependency: libtirpc.so.1()(64bit) for package: rpcbind-0.2.0-11.el6.x86_64 
--> Processing Dependency: libgssglue.so.1()(64bit) for package: rpcbind-0.2.0-11.el6.x86_64 
--> Running transaction check 
---> Package cyrus-sasl-lib.x86_64 0:2.1.23-15.el6 will be updated 
---> Package cyrus-sasl-lib.x86_64 0:2.1.23-15.el6_6.2 will be an update 
---> Package kernel.x86_64 0:2.6.32-504.30.3.el6 will be installed 
--> Processing Dependency: kernel-firmware >= 2.6.32-504.30.3.el6 for package: kernel-2.6.32-504.30.3.el6.x86_64 
--> Processing Dependency: grubby >= 7.0.4-1 for package: kernel-2.6.32-504.30.3.el6.x86_64 
--> Processing Dependency: dracut-kernel >= 004-356.el6_6.3 for package: kernel-2.6.32-504.30.3.el6.x86_64 
--> Processing Dependency: /sbin/new-kernel-pkg for package: kernel-2.6.32-504.30.3.el6.x86_64 
--> Processing Dependency: /sbin/new-kernel-pkg for package: kernel-2.6.32-504.30.3.el6.x86_64 
---> Package libgssglue.x86_64 0:0.1-11.el6 will be installed 
---> Package libtirpc.x86_64 0:0.2.1-10.el6 will be installed 
--> Running transaction check 
---> Package dracut-kernel.noarch 0:004-356.el6_6.3 will be installed 
--> Processing Dependency: dracut = 004-356.el6_6.3 for package: dracut-kernel-004-356.el6_6.3.noarch 
---> Package grubby.x86_64 0:7.0.15-7.el6 will be installed 
---> Package kernel-firmware.noarch 0:2.6.32-504.30.3.el6 will be installed 
--> Running transaction check 
---> Package dracut.noarch 0:004-356.el6_6.3 will be installed 
--> Processing Dependency: plymouth >= 0.8.0-0.2009.29.09.19.1 for package: dracut-004-356.el6_6.3.noarch 
--> Processing Dependency: plymouth-scripts for package: dracut-004-356.el6_6.3.noarch 
--> Processing Dependency: kbd for package: dracut-004-356.el6_6.3.noarch 
--> Processing Dependency: dash for package: dracut-004-356.el6_6.3.noarch 
--> Running transaction check 
---> Package dash.x86_64 0:0.5.5.1-4.el6 will be installed 
---> Package kbd.x86_64 0:1.15-11.el6 will be installed 
--> Processing Dependency: kbd-misc = 1.15-11.el6 for package: kbd-1.15-11.el6.x86_64 
---> Package plymouth.x86_64 0:0.8.3-27.el6.centos.1 will be installed 
--> Processing Dependency: plymouth-core-libs = 0.8.3-27.el6.centos.1 for package: plymouth-0.8.3-27.el6.centos.1.x86_64 
--> Processing Dependency: system-logos for package: plymouth-0.8.3-27.el6.centos.1.x86_64 
--> Processing Dependency: libply.so.2()(64bit) for package: plymouth-0.8.3-27.el6.centos.1.x86_64 
--> Processing Dependency: libply-splash-core.so.2()(64bit) for package: plymouth-0.8.3-27.el6.centos.1.x86_64 
--> Processing Dependency: libdrm_radeon.so.1()(64bit) for package: plymouth-0.8.3-27.el6.centos.1.x86_64 
--> Processing Dependency: libdrm_nouveau.so.1()(64bit) for package: plymouth-0.8.3-27.el6.centos.1.x86_64 
--> Processing Dependency: libdrm_intel.so.1()(64bit) for package: plymouth-0.8.3-27.el6.centos.1.x86_64 
--> Processing Dependency: libdrm.so.2()(64bit) for package: plymouth-0.8.3-27.el6.centos.1.x86_64 
---> Package plymouth-scripts.x86_64 0:0.8.3-27.el6.centos.1 will be installed 
--> Running transaction check 
---> Package kbd-misc.noarch 0:1.15-11.el6 will be installed 
---> Package libdrm.x86_64 0:2.4.52-4.el6 will be installed 
--> Processing Dependency: libpciaccess.so.0()(64bit) for package: libdrm-2.4.52-4.el6.x86_64 
---> Package plymouth-core-libs.x86_64 0:0.8.3-27.el6.centos.1 will be installed 
---> Package redhat-logos.noarch 0:60.0.14-12.el6.centos will be installed 
--> Running transaction check 
---> Package libpciaccess.x86_64 0:0.13.3-0.1.el6 will be installed 
--> Finished Dependency Resolution 

Dependencies Resolved 

================================================================================ 
Package Arch Version Repository Size 
================================================================================ 
Installing: 
cloudera-manager-agent x86_64 5.4.3-1.cm543.p0.258.el6 cloudera-manager 4.6 M 
Installing for dependencies: 
cloudera-manager-daemons 
x86_64 5.4.3-1.cm543.p0.258.el6 cloudera-manager 638 M 
cyrus-sasl-gssapi x86_64 2.1.23-15.el6_6.2 updates 34 k 
cyrus-sasl-plain x86_64 2.1.23-15.el6_6.2 updates 31 k 
dash x86_64 0.5.5.1-4.el6 base 74 k 
dracut noarch 004-356.el6_6.3 updates 123 k 
dracut-kernel noarch 004-356.el6_6.3 updates 25 k 
fuse x86_64 2.8.3-4.el6 base 71 k 
fuse-libs x86_64 2.8.3-4.el6 base 74 k 
grubby x86_64 7.0.15-7.el6 base 43 k 
kbd x86_64 1.15-11.el6 base 264 k 
kbd-misc noarch 1.15-11.el6 base 923 k 
kernel x86_64 2.6.32-504.30.3.el6 updates 29 M 
kernel-firmware noarch 2.6.32-504.30.3.el6 updates 14 M 
libdrm x86_64 2.4.52-4.el6 base 123 k 
libgssglue x86_64 0.1-11.el6 base 23 k 
libpciaccess x86_64 0.13.3-0.1.el6 base 24 k 
libtirpc x86_64 0.2.1-10.el6 base 79 k 
libxslt x86_64 1.1.26-2.el6_3.1 base 452 k 
plymouth x86_64 0.8.3-27.el6.centos.1 base 89 k 
plymouth-core-libs x86_64 0.8.3-27.el6.centos.1 base 88 k 
plymouth-scripts x86_64 0.8.3-27.el6.centos.1 base 31 k 
redhat-logos noarch 60.0.14-12.el6.centos base 15 M 
rpcbind x86_64 0.2.0-11.el6 base 51 k 
Updating for dependencies: 
cyrus-sasl-lib x86_64 2.1.23-15.el6_6.2 updates 136 k 

Transaction Summary 
================================================================================ 
Install 24 Package(s) 
Upgrade 1 Package(s) 

Total download size: 704 M 
Downloading Packages: 
Setting up and reading Presto delta metadata 
Processing delta metadata 
/usr/share/doc/cyrus-sasl-lib-2.1.23/AUTHORS: No such file or directory 
/usr/share/doc/cyrus-sasl-lib-2.1.23/COPYING: No such file or directory 
/usr/share/doc/cyrus-sasl-lib-2.1.23/NEWS: No such file or directory 
/usr/share/doc/cyrus-sasl-lib-2.1.23/README: No such file or directory 
/usr/share/doc/cyrus-sasl-lib-2.1.23/advanced.html: No such file or directory 
/usr/share/doc/cyrus-sasl-lib-2.1.23/appconvert.html: No such file or directory 
/usr/share/doc/cyrus-sasl-lib-2.1.23/components.html: No such file or directory 
/usr/share/doc/cyrus-sasl-lib-2.1.23/gssapi.html: No such file or directory 
/usr/share/doc/cyrus-sasl-lib-2.1.23/index.html: No such file or directory 
/usr/share/doc/cyrus-sasl-lib-2.1.23/install.html: No such file or directory 
/usr/share/doc/cyrus-sasl-lib-2.1.23/macosx.html: No such file or directory 
/usr/share/doc/cyrus-sasl-lib-2.1.23/mechanisms.html: No such file or directory 
/usr/share/doc/cyrus-sasl-lib-2.1.23/options.html: No such file or directory 
/usr/share/doc/cyrus-sasl-lib-2.1.23/plugprog.html: No such file or directory 
/usr/share/doc/cyrus-sasl-lib-2.1.23/programming.html: No such file or directory 
/usr/share/doc/cyrus-sasl-lib-2.1.23/readme.html: No such file or directory 
/usr/share/doc/cyrus-sasl-lib-2.1.23/sysadmin.html: No such file or directory 
/usr/share/doc/cyrus-sasl-lib-2.1.23/upgrading.html: No such file or directory 
/usr/share/doc/cyrus-sasl-lib-2.1.23/windows.html: No such file or directory 
delta does not match installed data 
Package(s) data still to download: 704 M 
-------------------------------------------------------------------------------- 
Total 161 kB/s | 704 MB 74:23 
Running rpm_check_debug 
Running Transaction Test 
Transaction Test Succeeded 
Running Transaction 
Installing : libgssglue-0.1-11.el6.x86_64 1/26 
Installing : plymouth-scripts-0.8.3-27.el6.centos.1.x86_64 2/26 
Updating : cyrus-sasl-lib-2.1.23-15.el6_6.2.x86_64 3/26 
Installing : cyrus-sasl-gssapi-2.1.23-15.el6_6.2.x86_64 4/26 
Installing : cyrus-sasl-plain-2.1.23-15.el6_6.2.x86_64 5/26 
Installing : libtirpc-0.2.1-10.el6.x86_64 6/26 
Installing : rpcbind-0.2.0-11.el6.x86_64 7/26 
Installing : kernel-firmware-2.6.32-504.30.3.el6.noarch 8/26 
Installing : libxslt-1.1.26-2.el6_3.1.x86_64 9/26 
Installing : redhat-logos-60.0.14-12.el6.centos.noarch 10/26 
Installing : grubby-7.0.15-7.el6.x86_64 11/26 
Installing : fuse-libs-2.8.3-4.el6.x86_64 12/26 
Installing : dash-0.5.5.1-4.el6.x86_64 13/26 
Installing : kbd-misc-1.15-11.el6.noarch 14/26 
Installing : kbd-1.15-11.el6.x86_64 15/26 
Installing : cloudera-manager-daemons-5.4.3-1.cm543.p0.258.el6.x86_64 16/26 
Installing : libpciaccess-0.13.3-0.1.el6.x86_64 17/26 
Installing : libdrm-2.4.52-4.el6.x86_64 18/26 
Installing : plymouth-core-libs-0.8.3-27.el6.centos.1.x86_64 19/26 
Installing : plymouth-0.8.3-27.el6.centos.1.x86_64 20/26 
Installing : dracut-004-356.el6_6.3.noarch 21/26 
Installing : dracut-kernel-004-356.el6_6.3.noarch 22/26 
Installing : kernel-2.6.32-504.30.3.el6.x86_64 23/26 
Installing : fuse-2.8.3-4.el6.x86_64 24/26 
Installing : cloudera-manager-agent-5.4.3-1.cm543.p0.258.el6.x86_64 25/26 
Cleanup : cyrus-sasl-lib-2.1.23-15.el6.x86_64 26/26 
Verifying : plymouth-core-libs-0.8.3-27.el6.centos.1.x86_64 1/26 
Verifying : libdrm-2.4.52-4.el6.x86_64 2/26 
Verifying : libpciaccess-0.13.3-0.1.el6.x86_64 3/26 
Verifying : dracut-004-356.el6_6.3.noarch 4/26 
Verifying : cloudera-manager-daemons-5.4.3-1.cm543.p0.258.el6.x86_64 5/26 
Verifying : kbd-misc-1.15-11.el6.noarch 6/26 
Verifying : cyrus-sasl-gssapi-2.1.23-15.el6_6.2.x86_64 7/26 
Verifying : dash-0.5.5.1-4.el6.x86_64 8/26 
Verifying : dracut-kernel-004-356.el6_6.3.noarch 9/26 
Verifying : cyrus-sasl-plain-2.1.23-15.el6_6.2.x86_64 10/26 
Verifying : cyrus-sasl-lib-2.1.23-15.el6_6.2.x86_64 11/26 
Verifying : fuse-libs-2.8.3-4.el6.x86_64 12/26 
Verifying : grubby-7.0.15-7.el6.x86_64 13/26 
Verifying : rpcbind-0.2.0-11.el6.x86_64 14/26 
Verifying : plymouth-scripts-0.8.3-27.el6.centos.1.x86_64 15/26 
Verifying : kernel-2.6.32-504.30.3.el6.x86_64 16/26 
Verifying : cloudera-manager-agent-5.4.3-1.cm543.p0.258.el6.x86_64 17/26 
Verifying : kbd-1.15-11.el6.x86_64 18/26 
Verifying : plymouth-0.8.3-27.el6.centos.1.x86_64 19/26 
Verifying : redhat-logos-60.0.14-12.el6.centos.noarch 20/26 
Verifying : fuse-2.8.3-4.el6.x86_64 21/26 
Verifying : libtirpc-0.2.1-10.el6.x86_64 22/26 
Verifying : libgssglue-0.1-11.el6.x86_64 23/26 
Verifying : libxslt-1.1.26-2.el6_3.1.x86_64 24/26 
Verifying : kernel-firmware-2.6.32-504.30.3.el6.noarch 25/26 
Verifying : cyrus-sasl-lib-2.1.23-15.el6.x86_64 26/26 

Installed: 
cloudera-manager-agent.x86_64 0:5.4.3-1.cm543.p0.258.el6 

Dependency Installed: 
cloudera-manager-daemons.x86_64 0:5.4.3-1.cm543.p0.258.el6 
cyrus-sasl-gssapi.x86_64 0:2.1.23-15.el6_6.2 
cyrus-sasl-plain.x86_64 0:2.1.23-15.el6_6.2 
dash.x86_64 0:0.5.5.1-4.el6 
dracut.noarch 0:004-356.el6_6.3 
dracut-kernel.noarch 0:004-356.el6_6.3 
fuse.x86_64 0:2.8.3-4.el6 
fuse-libs.x86_64 0:2.8.3-4.el6 
grubby.x86_64 0:7.0.15-7.el6 
kbd.x86_64 0:1.15-11.el6 
kbd-misc.noarch 0:1.15-11.el6 
kernel.x86_64 0:2.6.32-504.30.3.el6 
kernel-firmware.noarch 0:2.6.32-504.30.3.el6 
libdrm.x86_64 0:2.4.52-4.el6 
libgssglue.x86_64 0:0.1-11.el6 
libpciaccess.x86_64 0:0.13.3-0.1.el6 
libtirpc.x86_64 0:0.2.1-10.el6 
libxslt.x86_64 0:1.1.26-2.el6_3.1 
plymouth.x86_64 0:0.8.3-27.el6.centos.1 
plymouth-core-libs.x86_64 0:0.8.3-27.el6.centos.1 
plymouth-scripts.x86_64 0:0.8.3-27.el6.centos.1 
redhat-logos.noarch 0:60.0.14-12.el6.centos 
rpcbind.x86_64 0:0.2.0-11.el6 

Dependency Updated: 
cyrus-sasl-lib.x86_64 0:2.1.23-15.el6_6.2 

Complete! 
END (0) 
remote package cloudera-manager-agent installed 
Installing cloudera-manager-daemons package...
BEGIN yum list installed cloudera-manager-daemons 
Loaded plugins: presto 
Installed Packages 
cloudera-manager-daemons.x86_64 5.4.3-1.cm543.p0.258.el6 @cloudera-manager 
END (0) 
BEGIN echo jdk oracle-j2sdk1.7 cloudera-manager-agent cloudera-manager-daemons | grep cloudera-manager-daemons 
END (0) 
jdk oracle-j2sdk1.7 cloudera-manager-agent cloudera-manager-daemons 
BEGIN yum info cloudera-manager-daemons 
Loaded plugins: presto 
Installed Packages 
Name : cloudera-manager-daemons 
Arch : x86_64 
Version : 5.4.3 
Release : 1.cm543.p0.258.el6 
Size : 902 M 
Repo : installed 
From repo : cloudera-manager 
Summary : Provides daemons for monitoring Hadoop and related tools. 
URL : http://www.cloudera.com 
License : Proprietary 
Description : This package includes daemons for monitoring and managing Hadoop. 

END (0) 
Version : 5.4.3 
Release : 1.cm543.p0.258.el6 
BEGIN yum -y install cloudera-manager-daemons 
Loaded plugins: presto 
Setting up Install Process 
Package cloudera-manager-daemons-5.4.3-1.cm543.p0.258.el6.x86_64 already installed and latest version 
Nothing to do 
END (0) 
remote package cloudera-manager-daemons installed 
Installing Unlimited Strength Encryption policy files.
Installation not requested. Step will be skipped. 
Configuring Cloudera Manager Agent...
BEGIN grep server_host=172.17.0.6 /etc/cloudera-scm-agent/config.ini 
END (1) 
BEGIN sed -e 's/\(server_host=\).*/\1172.17.0.6/' -i /etc/cloudera-scm-agent/config.ini 
END (0) 
scm agent configured 


BEGIN /sbin/service cloudera-scm-agent status | grep running 

tail -n 50 /var/log/cloudera-scm-agent//cloudera-scm-agent.log | sed 's/^/>>/' 
BEGIN /sbin/service cloudera-scm-agent start