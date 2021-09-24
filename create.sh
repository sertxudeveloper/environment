#!/bin/bash

read -p "Domain: " PROJECT_DOMAIN

openssl genrsa -out /home/${PROJECT_DOMAIN}/nginx.key 2048

openssl req -new -key /home/${PROJECT_DOMAIN}/nginx.key \
  -subj "/C=ES/ST=Valencia/L=Spain/O=Sertxu Developer/OU=Local Development/CN=${PROJECT_DOMAIN}" \
  -extensions SAN -reqexts SAN \
  -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:${PROJECT_DOMAIN},DNS:*.${PROJECT_DOMAIN}")) \
  -out /home/${PROJECT_DOMAIN}/nginx.pem

openssl x509 -req -in /home/${PROJECT_DOMAIN}/nginx.pem \
  -extfile <(printf "subjectAltName=DNS:${PROJECT_DOMAIN},DNS:*.${PROJECT_DOMAIN}") \
  -CA /vagrant/rootCA.pem -CAkey /vagrant/rootCA.key -CAcreateserial \
  -out /home/${PROJECT_DOMAIN}/nginx.pem -days 500

