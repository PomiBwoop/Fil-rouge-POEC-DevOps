# Mise en place d'une solution de monitoring

## Minikube

### Installation

```sh
# Téléchargement du binaire
wget -O ./minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube
sudo mkdir -p /usr/local/bin/

# Copie du binaire
sudo install minikube /usr/local/bin/
```

### Démarrage

```sh
minikube start
```

## kubectl

### Installation

```sh
sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
sudo chmod +x kubectl
sudo mv kubectl  /usr/bin/
```

## Helm

### Installation 

```sh
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### Installation des repos Helm

```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### Installation du chart prometheus

```sh
helm install prometheus prometheus-community/kube-prometheus-stack
```

### Vérification des Pods créés

```sh
kubectl get po
```

### Vérification des services créés

```sh
kubectl get svc
```

## Grafana

```sh
kubectl port-forward --address 0.0.0.0 svc/prometheus-grafana 8000:80 &
# Grafana est exposé sur le port 8000

# Récupérer le hash du mot de passe 
kubectl get secret prometheus-grafana -o yaml | grep "admin-password"

# Remplacer `passwordHash` par le hash obtenu
echo Mot de passe de admin : $(echo "passwordHash" | base64 --decode)
```

Dans virtualbox, faire une redirection du port 8000 de la VM vers un port de la machine physique.

## Prometheus

```sh
kubectl port-forward --address 0.0.0.0 svc/prometheus-kube-prometheus-prometheus 9090 &
# Prometheus est exposé sur le port 9090
```

Dans virtualbox, faire une redirection du port 9090 de la VM vers un port de la machine physique.

