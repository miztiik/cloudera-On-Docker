##################################################################################
## 
## VERSION		: 0.0.1
## DATE			: 14Aug2015
##                
## USAGE		: Rancher OS Setup
##################################################################################


# http://docs.rancher.com/os/configuration/networking/
# Set the network configurations so it will start on a known IP each time.
ros config set network.interfaces.eth1.address 192.168.56.50/24
ros config set network.interfaces.eth1.gateway 192.168.0.0
ros config set network.interfaces.eth1.mtu 1500
ros config set network.interfaces.eth1.dhcp false
