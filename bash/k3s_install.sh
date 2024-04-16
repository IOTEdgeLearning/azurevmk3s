#! /bin/bash

set -euo pipefail

sudo apt update -y              && \
sudo apt update -y              && \
sudo apt install -y docker.io   && \
sudo systemctl enable docker    && \
sudo systemctl start docker     && \
sudo usermod -aG docker "$USER" && \
echo "Docker installed and started successfully"

self_public_ip=$(curl ifconfig.me)

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --tls-san='$self_public_ip'" sh -s -

sudo chmod 644 /etc/rancher/k3s/k3s.yaml

sudo systemctl start k3s  && \
sudo systemctl enable k3s

echo "K3S install successfully"
