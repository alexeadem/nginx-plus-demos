#!/bin/bash
echo "---installing qbo---"
## setup
echo "dir $1"
# make dir
mkdir -p $1/.qbo
# pull container
repo="eadem/qbo:latest"
docker pull $repo
# config
qboconfig=$(cat -<<EOF
# -----BEGIN QBO CONFIG-----
# Run or add the lines below to ~/.bashrc
# qbo
alias qbo="docker run -t --user=$(cat /etc/passwd | grep codespace: | awk -F ':' '{print $3}'):$(cat /etc/group | grep docker: | awk -F ':' '{print $3}') -v /var/run/docker.sock:/var/run/docker.sock -v $1/.qbo:/tmp/qbo ${repo} qbo"
# kubeconfig
export KUBECONFIG=$1/.qbo/admin.conf
# -----END QBO CONFIG-----
EOF
)
echo "$qboconfig" >> /home/codespace/.bashrc
echo "---finished installing qbo---"