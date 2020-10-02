# https://helm.sh/docs/intro/install/

curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh 
./get_helm.sh 
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update
kubectl create namespace monitoring
helm install prometheus-operator --namespace monitoring stable/prometheus-operator     --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false     --set grafana.sidecar.dashboards.enabled=true
kubectl --namespace default get pods --namespace=monitoring --watch

