# Déployement de l'infrastructure du projet

Notre projet utilise un certain nombre de VM : 
- le manager Ansible, qui serviera à la gestion des configurations des machines,
- la staging, pour la réalisation des tests de l'image buildée,
- la préPROD, pour déployer l'application dans sa globalité,
- la PROD, qui exposera l'application pour l'utilisation normale,
- le monitoring, qui réalisera la supervision des VM et services déployés.

Le déployement sera réalisé en deux phases : 
- le provisionnement des VM à l'aide de Vagrant,
- la configuration des VM grâce à Ansible.


## Provisionnement des VM

Nous allons provisionner 5 VM : `manager`, `staging`, `preprod`, `prod`, `monitoring` via le Vagrantfile, qui appelera un script bash `install_requirements.sh` dont le rôle est d'installer Ansible sur le `manager` et python3 sur les autres.

Exemple de VM provisionnée via le Vagrantfile :

```ruby
config.vm.define "manager" do |ansible|
    ansible.vm.box = "debian/bullseye64"
    ansible.vm.network "private_network", type: "static", ip: "192.168.99.1",
        virtualbox__intnet: true
    ansible.vm.hostname = "manager"
    ansible.vm.provider "virtualbox" do |v|
        v.name = "manager"
        v.memory = 4096
        v.cpus = 4
    end
    ansible.vm.provision :shell do |shell|
        shell.path = "install_requirements.sh"
        shell.args = ["manager"]
    end
end
```

Le script `install_requirements.sh` :

```sh
#!/bin/bash

# Change password for user vagrant
echo "vagrant:vagrant" | chpasswd

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
```

## Gestion de la configuration

## ngrok network

### Installation

```sh
# Téléchargement de l'archive
wget -O ngrok.tgz https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz

# Extraction du binaire
tar -xvf ngrok.tgz

# Configuration - Ajout du token
./ngrok config add-authtoken 2BnVZWluvNOYFHgdFPg5CSDjjLG_58f29zRoAC1bxajEUTZNr
```


### Mise en place d'une redirection de port

```sh
# Lancement de la redirection du port 22
./ngrok tcp 22
```
