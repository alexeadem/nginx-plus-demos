#!/bin/sh
shopt -s expand_aliases
alias qbo='docker run -t --user=1000:993 -v /var/run/docker.sock:/var/run/docker.sock -v /home/centos/.qbo:/tmp/qbo eadem/qbo:latest qbo'


# Creating cluster
echo -e "\033[34m -- Creating Kubernetes cluster\033[0m"
qbo add cluster -d`hostname` -w2 -p5000
# Starting registry
echo -e "\033[34m -- Starting registry\033[0m"
kubectl apply -f qbo-ctl/conf/registry.yaml 
while [[ $(kubectl get pods -n=kube-system -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}' | grep False) != "" ]]; 
    do echo "............................" && sleep 3;
done

# Check for registry to be ready
while [[ $(curl --write-out '%{http_code}' --silent --output /dev/null localhost:5000/v2/_catalog) != 200 ]];
   do echo "............................" && sleep 3;
done


# Starting endpoints
echo -e "\033[34m -- Running endpoints\033[0m"
        kubectl apply -f nginx/ngxscan/ngxscan-deploy.yaml

echo -e "\033[34m Building apache image\033[0m"
        cd nginx/apache2
        docker build -t apache2:latest -f Dockerfile .
        docker tag apache2:latest localhost:5000/apache2:latest
        docker push localhost:5000/apache2:latest
        cd -

# Building ngxscan image
echo -e "\033[34m Building ngxscan image\033[0m"
        v=`nginx/ngxscan/docker/ngxscan_x86-64 version`
        i="ngxscan"
        ip="localhost"
        cd nginx/ngxscan
        docker build --build-arg USER=$(whoami) --build-arg UID=$(id -u) -t $i:$v -f  docker/Dockerfile .
        docker tag $i:$v $ip:5000/$i:$v
        docker push $ip:5000/$i:$v
# Running ngxscan image
echo -e "\033[34m -- Running ngxscan image\033[0m"
        kubectl apply -f ngxscan.yaml
# Waiting for components to `start`
echo -e "\033[34m -- Waiting for components to start\033[0m"
while [[ $(kubectl get pods -n=default -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}' | grep False) != "" ]]; 
    do echo "............................" && sleep 3;
done
printf "\n"
echo "OK READY! Entering the NGINX Discover pod..."; kubectl exec -it $(kubectl get pods -lapp=ngxscan -o   jsonpath='{.items[*].metadata.name}') -- /bin/bash



