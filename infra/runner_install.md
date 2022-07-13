# Installation d'un runner gitlab

## Téléchargement et installation du binaire

```sh
# Download the binary for your system
sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64

# Give it permission to execute
sudo chmod +x /usr/local/bin/gitlab-runner

# Create a GitLab Runner user
sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash

# Install and run as a service
sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
sudo gitlab-runner start
```


## Configuration de l'URI et port d'écoute (via ngrok)

La valeur `Forwarding` de ngrok est récupérée puis ajoutée à la configuration de GitLab Runner.

```sh
cat << EOF > ~/.gitlab-runner/config.toml
[session_server]
  listen_address = [ngrok_uri]:[ngrok_port]
EOF
```

## Enregistrement du runner

Il faut spécifier notre token gitlab pour lier le runner local à gitlab.

```sh
GITLAB_RUNNER_TOKEN=GR1348941zgLYXgM32gTfBuyWAgvY

sudo gitlab-runner register --url https://gitlab.com/ \
    --registration-token "GR1348941zgLYXgM32gTfBuyWAgvY" \
    --tag-list "docker,alpine,ib-bdx" \
    --name "staging" \
    --executor "docker" \
    --docker-image "alpine:latest"
```

Il faut ensuite renseigner en mode interactif les propriétés de notre `runner` :

```log
Runtime platform                                    arch=amd64 os=linux pid=1068 revision=76984217 version=15.1.0
Running in system-mode.

Enter the GitLab instance URL (for example, https://gitlab.com/):
[https://gitlab.com/]:
Enter the registration token:
[GR1348941zgLYXgM32gTfBuyWAgvY]:
Enter a description for the runner:
[staging]:
Enter tags for the runner (comma-separated):
vm,debian,devops,ib-bdx
Enter optional maintenance note for the runner:

Registering runner... succeeded                     runner=GR1348941vjTQ2i8S
Enter an executor: parallels, ssh, virtualbox, docker+machine, docker, docker-ssh, shell, docker-ssh+machine, kubernetes, custom:
docker
Enter the default Docker image (for example, ruby:2.7):
alpine:latest
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!
```

## Verification dans Gitlab.com que le runner est bien déclaré et opérationnel

![Gitlab - Runner](./gitlab_runner.png)

Le runner est bien fonctionnel.

## Utilisation

Pour utiliser notre runner lors de l'exécution du pipeline, il faut spécifier des tags dans les tâches.

```yml
job:
  tags:
    - docker
    - ib-bdx
```

[Doc](https://docs.gitlab.com/ee/ci/yaml/index.html#tags)

## Résolution de problème

Dans le cas-où le runner ne serait pas à l'état up dans gitlab et aurait le message "not contacted the instance", il faut exécuter la commande :

```sh
sudo gitlab-runner verify
```
