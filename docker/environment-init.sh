#!/bin/bash

# Install Apache and DNS servers
sudo apt-get update
sudo apt-get install -y apache2
sudo a2enmod proxy proxy_http rewrite ssl
sudo apt-get install -y bind9
sudo chown bind:bind /var/cache/bind

# Download latest Docker
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add group docker to current user
sudo usermod -aG docker $USER
sudo su -s $USER

# Create docker network
docker network create -d bridge --subnet=172.18.0.0/16 docker-net

# Add own DNS to Docker
sudo su -
echo '{' >> /etc/docker/daemon.json
echo '    "dns": ["10.1.2.3", "8.8.8.8"]' >> /etc/docker/daemon.json
echo '}' >> /etc/docker/daemon.json

# Configure DNS
sed -ri -e "s?#DNS=?DNS=127.0.0.1?g" /etc/systemd/resolved.conf

# Create Root CA
openssl genrsa -out /home/vagrant/docker/rootCA.key 2048
openssl req -x509 -new -nodes -key /home/vagrant/docker/rootCA.key -days 1024 -subj "/C=ES/ST=Valencia/L=Spain/O=Sertxu Developer/OU=Local Development/CN=Sertxu Developer" -out /home/vagrant/docker/rootCA.pem

# Build images
docker build --tag laravel:1.0 /home/vagrant/docker/@images/laravel
docker build --tag mariadb:1.0 /home/vagrant/docker/@images/mariadb
docker build --tag website:1.0 /home/vagrant/docker/@images/website
docker build --tag nodejs:1.0 /home/vagrant/docker/@images/nodejs
