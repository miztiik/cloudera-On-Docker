#!/bin/bash
set -x
##################################################################################
## Single Docker Host DNS setup using dnsmasq, This script should only be run the first time.
##
## VERSION		:0.0.1
## DATE			:23Jul2015
## Ref[1]		:http://wiredcraft.com/blog/dns-and-docker-containers/
## Ref[2]		:https://blog.amartynov.ru/archives/dnsmasq-docker-service-discovery/
##################################################################################

# Install if not already installed
if ! rpm -qa | grep -qw dnsmasq 2>&1 > /dev/null; then
	yum -y install dnsmasq
fi

# Pre-configure dnsmasq
sed -ri "s|listen-address=__LOCAL_IP__||g" /etc/dnsmasq.conf
echo 'listen-address=__LOCAL_IP__' >> /etc/dnsmasq.conf

# Remove any old configurations
sed -ri 's|listen-address=(.*)||g' /etc/dnsmasq.conf

# echo 'resolv-file=/etc/resolv.dnsmasq.conf' >> /etc/dnsmasq.conf
# echo 'conf-dir=/etc/dnsmasq.d'  >> /etc/dnsmasq.conf

sed -ri "s|log-facility=/var/log/dnsmasq||g" /etc/dnsmasq.conf
echo "log-facility=/var/log/dnsmasq" >> /etc/dnsmasq.conf

sed -ri "s|resolv-file=/etc/resolv.dnsmasq.conf||g" /etc/dnsmasq.conf
echo "resolv-file=/etc/resolv.dnsmasq.conf" >> /etc/dnsmasq.conf

echo 'nameserver 8.8.8.8' > /etc/resolv.dnsmasq.conf
echo 'nameserver 8.8.4.4' >> /etc/resolv.dnsmasq.conf


# Create a new Docker-related config file in /etc/dnsmasq.d
rm -rf /etc/dnsmasq.d/docker-dns
touch /etc/dnsmasq.d/docker-dns

cat > /etc/dnsmasq.d/docker-dns << EOF
	
# Location of additional host entries
addn-hosts=/etc/sysconfig/docker-container-hosts

interface=docker0

EOF

# Removing double blank lines
cp /etc/dnsmasq.conf /etc/old_dnsmasq.conf
awk -v RS='\n\n\n' 1 /etc/old_dnsmasq.conf >  /etc/dnsmasq.conf
rm /etc/old_dnsmasq.conf
