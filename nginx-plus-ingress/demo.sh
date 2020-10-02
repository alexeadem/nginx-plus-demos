#!/usr/bin/env sh

p=k8s/

usage ()
{
    echo "\033[33mUsage: \033[0m"
    echo "$0 [ build ]"
    echo "$0 [ run ]"
    echo "$0 [ delete ]"

    exit 0

}

if [ -z $1 ]; then
    usage
fi

if [ $1 = "build" ]; then

    #nginx-ingress
    #kubectl apply -f $p vsr-definition.yaml
    #kubectl apply -f $p vs-definition.yaml
    kubectl create ns nginx-ingress
    kubectl apply -f $p/deployments/rbac/rbac.yaml
    kubectl apply -f $p/deployments/common/ns-and-sa.yaml
    kubectl apply -f $p/deployments/daemon-set/nginx-plus-ingress.yaml
    kubectl apply -f $p/deployments/common/nginx-config.yaml
    kubectl apply -f $p/deployments/common/default-server-secret.yaml

    # example
    kubectl apply -f $p/complete-example/cafe-ingress.yaml  
    kubectl apply -f $p/complete-example/cafe-secret.yaml   
    kubectl apply -f $p/complete-example/cafe.yaml

elif [ $1 = "run" ]; then

    (set -x; curl  -L -s --resolve 'cafe.example.com:80:192.168.26.128' -D - http://cafe.example.com/coffee -o /dev/null -w 'http://cafe.example.com/coffe => %{url_effective}\n')

    #curl -k https://cafe.example.com:443/coffee
    #curl -k https://cafe.example.com:443/tea

    curl https://cafe.example.com/coffee -k --resolve cafe.example.com:443:192.168.26.128
    curl https://cafe.example.com/tea -k --resolve cafe.example.com:443:192.168.26.128

elif [ $1 = "delete" ]; then
    kubectl delete -f $p/deployments/rbac/rbac.yaml
    kubectl delete -f $p/deployments/common/ns-and-sa.yaml
    kubectl delete -f $p/deployments/deamon-set/nginx-plus-ingress.yaml
    #kubectl delete -f $p/deployments/common/nginx-config.yaml
    #kubectl delete -f $p/deployments/common/default-server-secret.yaml

    # example
    kubectl delete -f $p/complete-example/cafe-ingress.yaml  
    kubectl delete -f $p/complete-example/cafe-secret.yaml   
    kubectl delete -f $p/complete-example/cafe.yaml
    #kubectl delete ns nginx-ingress
else
    usage
fi
 

