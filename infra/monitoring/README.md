# Mise en place d'une solution de monitoring

## Helm

Installation

```sh
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

## Prometheus

```sh
kubectl create namespace monitoring

git clone https://github.com/eazytrainingfr/prometheus-training.git
mkdir -p ~/monitoring && cd ~/monitoring
cp ~/prometheus-training/sources/prometheus/* .
```

Edition du fichier `config-map.yaml`, ajout d'une entrée pour 

```sh
kubectl apply -f config-map.yaml
kubectl apply -f clusterRole.yaml
kubectl apply -f prometheus-deployment.yaml
kubectl apply -f prometheus-service.yaml
```

## Grafana

Installation

```sh
cp ~/prometheus-training/sources/grafana/* .
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install grafana-dashboard -f values.yaml  grafana/grafana --version 3.12.1
```

Authentification

```sh
kubectl get secret --namespace default grafana-dashboard -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services grafana-dashboard)
export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
echo http://$NODE_IP:$NODE_PORT
```

Configuration de la source de données : Prometheus

URI : http://prometheus-service.monitoring.svc:8090

Import du dashboard Prometheus id n° 3662.


## Exporters

### Node exporter

Afin de récupérer des métriques sur les différentes machines de notre infra, nous déployons un `node exporter` sur celles-ci.

#### Installation

```sh
wget -O node_exporter-linux-amd64.tar.gz https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
mkdir -p node_exporter-linux-amd64
tar xvfz node_exporter-linux-amd64.tar.gz -C node_exporter-linux-amd64 --strip-components 1
cd node_exporter-linux-amd64
./node_exporter
```

#### Vérification

Vérification locale du bon fonctionnement de l'exporteur.

```sh
curl 127.0.0.1:9100/metrics | grep "node_" | grep -v "^#"
```

Vérification que l'exporteur est à l'écoute sur l'IP de la machine (afin d'être accessible depuis Premetheus).

```sh
curl 192.168.99.10:9100/metrics | grep "node_" | grep -v "^#"
```


### Docker exporter

#### Mise en oeuvre

```sh
sudo vi /etc/docker/daemon.json
```

Ajouter 

```json
{
  "metrics-addr" : "192.168.99.##:9323",
  "experimental" : true
}
```

Redémarrer Docker pour prendre en compte les modifications

```sh
sudo systemctl restart docker.service
```

#### Vérification

Vérification que l'exporteur est à l'écoute sur l'IP de la machine (afin d'être accessible depuis Premetheus).

```sh
curl 192.168.99.##:9323/metrics
```

Rechargement de la configuration

```sh
kubectl delete configmaps prometheus-server-conf -n monitoring
kubectl create -f config-map.yaml
kubectl delete deployments.apps prometheus-deployment -n monitoring
kubectl apply -f prometheus-deployment.yaml -n monitoring
```