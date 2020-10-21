#!/bin/sh
shopt -s expand_aliases
alias qbo='docker run -t --user=1000:993 -v /var/run/docker.sock:/var/run/docker.sock -v /home/centos/.qbo:/tmp/qbo eadem/qbo:latest qbo'
qbo delete cluster
