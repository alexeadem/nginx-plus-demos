#!/bin/bash
echo "====setup qbo cluster===="
repo="eadem/qbo:latest"
# default cluster two workers with registry port open
docker run -t --user=$(cat /etc/passwd | grep codespace: | awk -F ':' '{print $3}'):$(cat /etc/group | grep docker: | awk -F ':' '{print $3}') -v /var/run/docker.sock:/var/run/docker.sock -v $1/.qbo:/tmp/qbo ${repo} qbo add cluster -w2 -d mylab.com -p 5000
# start registry
kubectl --kubeconfig $1/.qbo/admin.conf apply -f "https://raw.githubusercontent.com/alexeadem/qbo-ctl/master/conf/registry.yaml"
echo "====setup qbo cluster done===="