#! /bin/bash

set -euo pipefail

# Wait for instance to be up and running
sleep 15

echo Current Working Directory is "$PWD"

# Reduce SSH Private Key Permission with 600
chmod 600 "${identityFile}"

ssh -o StrictHostKeyChecking=no -i "${identityFile}" "${user}@${public_ip}" "sudo cat /etc/rancher/k3s/k3s.yaml" > "$PWD/k3s_config"

sed -i -e "s/127.0.0.1/${public_ip}/g" "$PWD/k3s_config"
