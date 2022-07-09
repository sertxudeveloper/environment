#!/bin/bash
apt update -y

# Install Docker
apt install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update -y
apt install -y docker-ce docker-ce-cli containerd.io

# Configure Docker
groupadd docker
usermod -aG docker $USER

chown "$USER":"$USER" "$HOME/.docker" -R
chmod g+rwx "$HOME/.docker" -R

docker network create -d bridge --subnet 172.18.0.0/16 docker-net

# Install Nginx
apt install -y nginx
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp

# Install Bind
apt install -y bind9

# Configure DNS
sed -ri -e "s!#DNS=!DNS=127.0.0.1!g" /etc/systemd/resolved.conf

