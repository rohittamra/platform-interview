#!/usr/bin/env bash

set -e

current_dir=`pwd`
echo Installing docker-compose
os=$(uname -s | tr '[:upper:]' '[:lower:]')
arch=$(uname -m)
pro=$(dpkg --print-architecture)
terraform_version="1.2.5"
sudo curl -L "https://github.com/docker/compose/releases/download/v2.1.1/docker-compose-${os}-${arch}" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

. "${HOME}/.profile"
echo Installing terraform onto machine...
echo "1st ${HOME}/bin"
mkdir -p "${HOME}/bin"
sudo apt-get update && sudo apt-get install -y unzip jq
echo "2nd 2nd ${HOME}/bin"
cd  "${HOME}/bin"

wget -q "https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_${pro}.zip"
unzip -q -o "terraform_${terraform_version}_linux_${pro}.zip"
cd $current_dir
echo "Switched back to the previous directory"
echo "Building Docker images..."
#cd /vagrant
echo "Switched to /vagrant directory"
ls -la
#docker build ./services/account -t form3tech-oss/platformtest-account
#docker build ./services/gateway -t form3tech-oss/platformtest-gateway
#docker build ./services/payment -t form3tech-oss/platformtest-payment
docker-compose up -d
echo Applying terraform script
cd $current_dir/tf
terraform init -upgrade
terraform apply -auto-approve
