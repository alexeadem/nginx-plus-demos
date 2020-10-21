#!/bin/sh
shopt -s expand_aliases
alias qbo='docker run -t --user=1000:993 -v /var/run/docker.sock:/var/run/docker.sock -v /home/centos/.qbo:/tmp/qbo eadem/qbo:latest qbo'


# Creating cluster
echo -e "\033[34m -- Creating Kubernetes cluster\033[0m"
qbo add cluster -d`hostname` -w2 -p5000
# Starting registry
echo -e "\033[34m -- Starting registry\033[0m"
/usr/bin/kubectl --kubeconfig=/home/centos/.qbo/admin.conf apply -f /home/centos/qbo-ctl/conf/registry.yaml
while [[ $(/usr/bin/kubectl --kubeconfig=/home/centos/.qbo/admin.conf get pods -n=kube-system -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}' | grep False) != "" ]]; 
    do echo "............................" && sleep 3;
done

echo -e "\033[32m -- ready\033[0m"

# Check for registry to be ready
echo -e "\033[34m -- Waiting for registry to be ready\033[0m"
while [[ $(/usr/bin/curl --write-out '%{http_code}' --silent --output /dev/null localhost:5000/v2/_catalog) != 200 ]];
   do echo "............................" && sleep 3;
done


echo -e "\033[32m -- ready\033[0m"
#systemd-notify --ready
