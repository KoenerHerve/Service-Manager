#!/bin/bash

if [ -f /mnt/context.sh ]
then
  . /mnt/context.sh
fi

echo $HOSTNAME > /etc/hostname
hostname $HOSTNAME
sed -i "/127.0.1.1/s/ubuntu/$HOSTNAME/" /etc/hosts

if [ -n "$IP" ]; then
	sudo ifconfig eth0 $IP
fi
 
if [ -n "$NETMASK" ]; then
	sudo ifconfig eth0 netmask $NETMASK
fi

if [ -f /mnt/$ROOT_PUBKEY ]; then
	mkdir -p /root/.ssh
	cat /mnt/$ROOT_PUBKEY >> /root/.ssh/authorized_keys
	chmod -R 600 /root/.ssh/
fi

# if [ -n "$USERNAME" ]; then
# 	useradd -s /bin/bash -m $USERNAME
# 	if [ -f /mnt/$USER_PUBKEY ]; then
# 		mkdir -p /home/$USERNAME/.ssh/
# 		cat /mnt/$USER_PUBKEY >> /home/$USERNAME/.ssh/authorized_keys
# 		chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
# 		chmod -R 600 /home/$USERNAME/.ssh/authorized_keys
# 	fi
# fi

if [ -f /mnt/service.rb ]; then
	if [ ! -e /servman ]; then
		mkdir /servman
		cp /mnt/service.rb /servman
		cp /mnt/client.rb /servman
		cp /mnt/cmd.sh /servman
	fi
	/servman/service.rb &
fi
