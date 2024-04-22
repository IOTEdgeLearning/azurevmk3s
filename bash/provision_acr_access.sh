#!/bin/bash

set -euo pipefail

while getopts u:s:p: flag
do
case "${flag}" 
in
    u) username=${OPTARG};;
    s) server=${OPTARG};;
    p) password=${OPTARG};;
esac
done

echo "username: $username"
echo "server: $server"
echo "password: $password"

# if [ "$server" ]; then
#     kubectl create secret docker-registry acrsecret \
#         --docker-server=$server.azurecr.io \
#         --docker-username=$username \
#         --docker-password=$password
# fi