#!/bin/bash
# install tools for container standup
echo "cwd: $(pwd)"
echo "---getting tools---"
sudo apt-get update
sudo apt-get install -y jq less
. .devcontainer/scripts/kubectl.sh
. .devcontainer/scripts/qbo.sh "$(pwd)"
. .devcontainer/scripts/qbo-cluster.sh "$(pwd)"
echo "---tools done---"