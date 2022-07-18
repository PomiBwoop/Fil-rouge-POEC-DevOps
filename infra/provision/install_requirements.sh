#!/bin/bash

# Change password for user vagrant
echo "vagrant:vagrant" | chpasswd

cat << EOF >> /etc/hosts
192.168.99.1  manager
192.168.99.2  monitoring
192.168.99.10 staging
192.168.99.20 preprod
192.168.99.30 prod
EOF

# Update packages list, upgrade packages and install python3
apt-get update; apt-get upgrade -y; apt-get install -y python3

if [ $1 == "manager" ]
then
  echo "Install ansible for manager host"
  # Adding the source
  echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu focal main" > /etc/apt/sources.list.d/ansible.list

  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367

  # Update packages list and install ansible
  apt-get update; apt-get install -y ansible sshpass

  # Generate the ssh keys
  ssh-keygen -t rsa -b 4096 -N "" -q -f /home/vagrant/.ssh/id_rsa
  chown vagrant: /home/vagrant/.ssh/id_rsa
fi

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# Restart sshd
systemctl restart sshd.service
