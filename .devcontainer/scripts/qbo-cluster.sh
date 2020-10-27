#!/bin/bash
echo "====setup qbo cluster===="
# default cluster two workers with registry port open
qbo add cluster -w2 -d mylab.com -p 5000
# start registry
kubectl --kubeconfig $1/.qbo/admin.conf apply -f "https://raw.githubusercontent.com/alexeadem/qbo-ctl/master/conf/registry.yaml"
echo "====setup qbo cluster done===="