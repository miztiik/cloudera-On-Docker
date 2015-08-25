##################################################################################
## 
## VERSION		:	0.0.3
## DATE			:	25Aug2015
##                
## USAGE		:	Dockerfile to build GUI applications within Docker, starting with firefox and uTorrent
## Ref [1]		:	http://tutorialforlinux.com/2014/07/20/how-to-install-utorrent-bittorrent-client-on-centos-6-x-32-64bit-linux-easy-guide/
## Ref [2]		:	http://www.ezylinux.com/en/how-to-install-utorrent-on-centos-6/
##################################################################################

FROM centos:6.6
MAINTAINER mystique <miztiik@gmail.com>

# Install necessary packages & Create sym link for libssl because the CentOS 6 has newer version than what uTorrent requires
RUN yum -y install wget glibc openssl libgcc unzip openssl098e; \
           ln -s /usr/lib64/libssl.so.0.9.8e /usr/lib64/libssl.so.0.9.8; \
           ln -s /usr/lib64/libcrypto.so.0.9.8e /usr/lib64/libcrypto.so.0.9.8; 

# Download tor and install install it
RUN cd /opt; \
    wget http://download.utorrent.com/linux/utorrent-server-3.0-ubuntu-10.10-27079.x64.tar.gz && \
    tar zxvf utorrent-server-3.0-ubuntu-10.10-27079.x64.tar.gz && \
    cd utorrent-server-v3_0 && \
    unzip webui.zip && \
    rm -rf utorrent-server-3.0-ubuntu-10.10-27079.x64.tar.gz
	
# Expose external connectivity port
EXPOSE 2891

# Expose the web interface
EXPOSE 8080

ENTRYPOINT ["/opt/utorrent-server-v3_0/utserver"]
CMD ["-settingspath", "/opt/utorrent-server-v3_0/"]

# Connect to gui @ localhost:8080/gui
# user name: admin
# pass:

## Usage : docker run -dti --name rotnode -p 28920:2891 -p 28921:8080 -v /media/sf_dockerRepos:/media/sf_dockerRepos <imageName> /bin/bash
