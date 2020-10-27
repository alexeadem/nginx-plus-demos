#!/bin/bash
echo "---installing kubectl---"
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
sudo mv kubectl /usr/bin/
sudo chmod +x /usr/bin/kubectl
echo "---finished installing kubectl---"