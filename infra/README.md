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

Ansible est utilisé afin de réaliser la configuration des hôtes listés dans le fichier d'inventaire :

```yml
all:
  hosts:
    manager:
    monitoring:
    staging:
    preprod:
    prod:
children:
  docker:
    hosts:
      staging:
      preprod:
      prod:
```

Il nous permet, par exemple, d'installer Docker.

Pour ce faire nous utilisons un role Ansible, qui sera executé sur les hosts du groupe `docker`, à savoir : staging, preprod, prod.

```sh
ansible-playbook docker.yml
```

Ce qui donne le résultat suivant (nous pouvons voir les différentes étapes sur chacun des hôtes) :

```log

PLAY [Docker & Docker compose installation] *************************************************************************

TASK [Gathering Facts] **********************************************************************************************
ok: [prod]
ok: [preprod]
ok: [staging]

TASK [docker : Update package's list and install requirements] ******************************************************
changed: [staging]
changed: [preprod]
changed: [prod]

TASK [docker : Add Docker repository key] ***************************************************************************
changed: [preprod]
changed: [prod]
changed: [staging]

TASK [docker : Add Docker repository] *******************************************************************************
changed: [preprod]
changed: [prod]
changed: [staging]

TASK [docker : Install docker's packages] ***************************************************************************
changed: [prod]
changed: [staging]
changed: [preprod]

TASK [docker : Download the version 2.6.0] **************************************************************************
changed: [preprod]
changed: [prod]
changed: [staging]

PLAY RECAP **********************************************************************************************************
preprod                    : ok=6    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
prod                       : ok=6    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
staging                    : ok=6    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```


## ngrok network

Ngrok permet d'effectuer une redirection de port afin d'exposer un port local sur Internet.

Nous l'utilisons afin que gitlab puisse dialoguer avec notre runner et faire les déployements.

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

Résultat 

```log
ngrok                                                                    (Ctrl+C to quit)
Join us in the ngrok community @ https://ngrok.com/slack

Session Status                online
Account                       user (Plan: Free)
Version                       3.0.6
Region                        Europe (eu)
Latency                       27ms
Web Interface                 http://127.0.0.1:4041
Forwarding                    tcp://0.tcp.eu.ngrok.io:11484 -> localhost:22

Connections                   ttl     opn     rt1     rt5     p50     p90
                              0       0       0.00    0.00    0.00    0.00
```

La valeur `Forwarding` est récupérée et passée à GitLab Runner.


## Gitlab Runner 

Cf. [Read-me mise en oeuvre d'un runner local](./runner_install.md)


## Monitoring 

Cf. [Read-me du monitoring](./monitoring/README.md)
