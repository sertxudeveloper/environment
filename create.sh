#!/bin/bash

SERVER_IP="10.0.0.30"

function createContainer {
    find "/home/vagrant/docker/${PROJECT_NAME}" -maxdepth 1 -type f -exec sed -ri "s!\{\{PROJECT_NAME\}\}!${PROJECT_NAME}!g" {} \;
    find "/home/vagrant/docker/${PROJECT_NAME}" -maxdepth 1 -type f -exec sed -ri "s!\{\{PROJECT_IP\}\}!${PROJECT_IP}!g" {} \;
}

function createSSL {
    openssl genrsa -out /home/vagrant/docker/${PROJECT_NAME}/apache_local.key 2048

    openssl req -new -key /home/vagrant/docker/${PROJECT_NAME}/apache_local.key \
      -subj "/C=ES/ST=Valencia/L=Spain/O=Sertxu Developer/OU=Local Development/CN=${PROJECT_DOMAIN}" \
      -extensions SAN -reqexts SAN \
      -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:${PROJECT_DOMAIN},DNS:*.${PROJECT_DOMAIN}")) \
      -out /home/vagrant/docker/${PROJECT_NAME}/apache_local.pem

    openssl x509 -req -in /home/vagrant/docker/${PROJECT_NAME}/apache_local.pem \
      -extfile <(printf "subjectAltName=DNS:${PROJECT_DOMAIN},DNS:*.${PROJECT_DOMAIN}") \
      -CA /home/vagrant/docker/rootCA.pem -CAkey /home/vagrant/docker/rootCA.key -CAcreateserial \
      -out /home/vagrant/docker/${PROJECT_NAME}/apache_local.pem -days 500
}

function registerProxy {
    cp "/etc/apache2/sites-available/blank.conf" "/etc/apache2/sites-available/${PROJECT_NAME}.conf"
    sed -ri -e "s!\{\{PROJECT_IP\}\}!${PROJECT_IP}!g" "/etc/apache2/sites-available/${PROJECT_NAME}.conf"
    sed -ri -e "s!\{\{PROJECT_NAME\}\}!${PROJECT_NAME}!g" "/etc/apache2/sites-available/${PROJECT_NAME}.conf"
    sed -ri -e "s!\{\{PROJECT_DOMAIN\}\}!${PROJECT_DOMAIN}!g" "/etc/apache2/sites-available/${PROJECT_NAME}.conf"
    sudo a2ensite ${PROJECT_NAME}.conf
    sudo systemctl restart apache2
}

function registerDNS {
    cp "/etc/bind/db.blank.local" "/etc/bind/db.${PROJECT_DOMAIN}"
    SERIAL=$(date +%Y%m%d)
    sed -ri -e "s!\{\{SERIAL\}\}!${SERIAL}!g" "/etc/bind/db.${PROJECT_DOMAIN}"
    sed -ri -e "s!\{\{SERVER_IP\}\}!${SERVER_IP}!g" "/etc/bind/db.${PROJECT_DOMAIN}"
    sed -ri -e "s!\{\{PROJECT_DOMAIN\}\}!${PROJECT_DOMAIN}!g" "/etc/bind/db.${PROJECT_DOMAIN}"

    echo "zone \"${PROJECT_DOMAIN}\" {" >> "/etc/bind/named.conf.local"
    echo "    type master;" >> "/etc/bind/named.conf.local"
    echo "    file \"/etc/bind/db.${PROJECT_DOMAIN}\";" >> "/etc/bind/named.conf.local"
    echo "};" >> "/etc/bind/named.conf.local"
    echo "" >> "/etc/bind/named.conf.local"

    sudo systemctl restart bind9
}

read -p "Container common name (sertxudeveloper, sertxuplayer): " PROJECT_NAME
read -p "Container IP (172.18.0.0/16): " PROJECT_IP
read -p "Container Domain ($PROJECT_NAME.local) (optional): " PROJECT_DOMAIN

if [ -z "$PROJECT_DOMAIN" ]
then
    PROJECT_DOMAIN="$PROJECT_NAME.local"
fi

# cp "/home/vagrant/docker/!stubs" "/home/vagrant/docker/$PROJECT_NAME"

mkdir "/home/vagrant/docker/${PROJECT_NAME}"

TYPES="laravel website nodejs mariadb"
select type in $TYPES; do
    if [ "$type" = "laravel" ]; then
        echo "Creating new Laravel project..."
        cp -r "/home/vagrant/docker/@stubs/laravel/." "/home/vagrant/docker/${PROJECT_NAME}"
        createContainer
        createSSL

        read -r -p "Create reverse proxy configuration? [y/N] " response
        response=${response,,}    # tolower
        if [[ "$response" =~ ^(yes|y)$ ]]; then
            registerProxy
        fi

        read -r -p "Create DNS configuration? [y/N] " response
        response=${response,,}    # tolower
        if [[ "$response" =~ ^(yes|y)$ ]]; then
            registerDNS
        fi

        bash /home/vagrant/docker/${PROJECT_NAME}/run.sh
        exit
    elif [ "$type" = "website" ]; then
        echo "Creating new Website project..."
        cp -r "/home/vagrant/docker/@stubs/website/." "/home/vagrant/docker/${PROJECT_NAME}"
        createContainer
        createSSL
        registerProxy
        registerDNS
        bash /home/vagrant/docker/${PROJECT_NAME}/run.sh
        exit
    elif [ "$type" = "nodejs" ]; then
        echo "Creating new Node.JS project..."
        cp -r "/home/vagrant/docker/@stubs/nodejs/." "/home/vagrant/docker/${PROJECT_NAME}"

        exit
    elif [ "$type" = "mariadb" ]; then
        echo "Creating new Maria database..."
        cp -r "/home/vagrant/docker/@stubs/mariadb/." "/home/vagrant/docker/${PROJECT_NAME}"
        createContainer
        bash /home/vagrant/docker/${PROJECT_NAME}/run.sh
        exit
    else
        clear
        echo "Type not available!"
    fi
done