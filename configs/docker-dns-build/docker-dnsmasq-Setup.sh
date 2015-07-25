#!/bin/bash
set -x
##################################################################################
## Single Docker Host DNS setup using dnsmasq, This script should only be run the first time.
##
## VERSION		:0.0.2
## DATE			:24Jul2015
## Ref[1]		:http://wiredcraft.com/blog/dns-and-docker-containers/
## Ref[2]		:https://blog.amartynov.ru/archives/dnsmasq-docker-service-discovery/
## Ref[3]		:http://www.itsprite.com/centoslinuxhow-to-set-up-a-dhcp-server-using-dnsmasq/
##################################################################################

# Install if not already installed
if ! rpm -qa | grep -qw dnsmasq 2>&1 > /dev/null; then
	yum -y install dnsmasq
fi

# The best way to create the config file is to take a backup copy of the old one and recreate a new one with the needed configs
mv -f /etc/dnsmasq.conf /etc/dnsmasq.conf_BckUp
> /etc/dnsmasq.conf

# Pre-configure dnsmasq
echo 'user=root' >> /etc/dnsmasq.conf
echo "log-queries" >> /etc/dnsmasq.conf
echo "expand-hosts" >> /etc/dnsmasq.conf
# Which IP should be really listening, 127.x.x.x or the docker0 interface?
echo 'listen-address=__LOCAL_IP__' >> /etc/dnsmasq.conf
echo 'interface=docker0' >> /etc/dnsmasq.conf
echo 'resolv-file=/etc/resolv.dnsmasq.conf' >> /etc/dnsmasq.conf
echo 'conf-dir=/etc/dnsmasq.d'  >> /etc/dnsmasq.conf
echo "log-facility=/var/log/dnsmasq" >> /etc/dnsmasq.conf
echo "domain=myhadoop-containers.com" >> /etc/dnsmasq.conf

# Get the docker host ip and update the DNS
IP=$(ip -o -4 addr list docker0 | perl -n -e 'if (m{inet\s([\d\.]+)\/\d+\s}xms) { print $1 }')

echo "nameserver ${IP}" > /etc/resolv.dnsmasq.conf
echo 'nameserver 8.8.4.4' >> /etc/resolv.dnsmasq.conf

# dhcp-range: it specifies the IP address range to lease out (e.g., from 10.1.1.50 to 10.1.1.200), and optionally lease time (e.g., 12 hours).
# dhcp-range=10.1.1.50,10.1.1.200,12h

# sed -ri "s|listen-address=__LOCAL_IP__||g" /etc/dnsmasq.conf
# 
# # Remove any old configurations
# sed -ri 's|listen-address=(.*)||g' /etc/dnsmasq.conf
# 
# sed -ri "s|log-facility=/var/log/dnsmasq||g" /etc/dnsmasq.conf
# 
# # sed -ri "s|expand-hosts||g" /etc/dnsmasq.conf
# 
# sed -ri "s|domain=myhadoop-containers.com||g" /etc/dnsmasq.conf
# 
# sed -ri "s|resolv-file=/etc/resolv.dnsmasq.conf||g" /etc/dnsmasq.conf


# Create a new Docker-related config file in /etc/dnsmasq.d
> /etc/dnsmasq.d/docker-dns
touch /etc/dnsmasq.d/docker-dns

cat > /etc/dnsmasq.d/docker-dns << EOF
	
# Location of additional host entries
addn-hosts=/docker-container-hosts
EOF

# Refresh the service with new configs
pkill -x -HUP dnsmasq
