# Dev Environment

This environment is used as a server with virtualization using Docker.

## System requirements

- Virtualbox
- Vagrant

## Installation

First you should create the VM using Vagrant.

```
C:\> vagrant up
```

Once Vagrant has ended creating the VM, we must execute as root the init.sh file inside the VM.

```
C:\> vagrant ssh
$ sudo bash init.sh
```

## Build images

After the script has installed Docker, Nginx and Bind9, we must build the docker images.<br>
These images are located at `/vagrant/home/@images`.

```
$ cd /vagrant/home/@images

$ docker build -t laravel:1.0 laravel
```


## Create new project

To create a new project, first we should create the required folders inside the `home` environment folder.<br>
As an example we're going to create a Laravel project with the `sertxudeveloper.test` domain.

The contents will have the following structure.

- Vagrantfile
- create.sh
- init.sh
- home/
  - @images
  - sertxudeloper.test
    - run.sh
    - data

Next we sould link the project folder located at the `home` environment folder with the system `home` folder.

```
$ sudo ln -s /vagrant/home/sertxudeveloper.test /home/sertxudeveloper.test
```

### Configure domain

Our environment has its own DNS server, we should create the DNS zone for the new domain.

```
$ sudo vi /etc/bind/named.conf.test
```

```
...
zone "sertxudeveloper.test" {
    type master;
    file "/etc/bind/db.sertxudeveloper.test";
};
```

-----

```
$ sudo vi /etc/bind/db.sertxudeveloper.test
```

```
$TTL 1d
$ORIGIN sertxudeveloper.test.

@ IN SOA sertxudeveloper.test. admin.sertxudeveloper.test. (
20200714 8h 15m 4w 1d)

* IN CNAME sertxudeveloper.test.

@ IN NS sertxudeveloper.test.
@ IN A 10.0.0.30
```

-----

```
$ sudo systemctl restart bind9
```

### Create SSL certificate

We should create a SSL certificate to be able to use HTTPS when accessing our project.

Our environment has its own root CA certificates so the browser can trust the self-signed certificates.

To create the certificate we must execute the `create.sh` script.

```
$ sudo bash create.sh
```

It will ask for the domain we want to generate the certificate, and will create a wildcard certificate so we only need one for all the subdomains.


### Configure reverse proxy

To be able to access our project we need to configure a reverse proxy.

```
$ sudo vi /etc/nginx/sites-available/sertxudeveloper.test
```

```nginx
server {
    listen 80;
    server_name sertxudeveloper.test;
    server_name www.sertxudeveloper.test;

    return 301 https://www.sertxudeveloper.test$request_uri;
}

server {
    listen 443 ssl;
    server_name sertxudeveloper.test;

    return 301 https://www.sertxudeveloper.test$request_uri;
}

server {
    listen 443 ssl;
    server_name www.sertxudeveloper.test;

    ssl_certificate /home/sertxudeveloper.test/nginx.pem;
    ssl_certificate_key /home/sertxudeveloper.test/nginx.key;

    location / {
        proxy_pass http://172.18.1.2;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

-----

Once we saved the reverse proxy configuration, we need to enable the site.

```
$ sudo ln -s /etc/nginx/sites-available/sertxudeveloper.test /etc/nginx/sites-enabled/sertxudeveloper.test
```

```
$ sudo systemctl restart nginx
```

## Trust SSL root CA

We need to add the root CA certificate to the local trusted entities.

### Ubuntu guest

```
$ sudo cp /vagrant/rootCA.crt /usr/local/share/ca-certificates/
$ sudo update-ca-certificates --fresh
```

### Docker container

```
$ docker cp /vagrant/rootCA.pem {container name}:/usr/local/share/ca-certificates
$ docker exec {container name} rm -f /usr/local/share/ca-certificates/certificate.crt
$ docker exec {container name} ln -s /usr/local/share/ca-certificates/rootCA.pem /etc/ssl/certs/
$ docker exec {container name} update-ca-certificates --fresh
```

## Change folders and files permissions

```
mkdir data
chown -R root:www-data data
chmod -R 2770 data
find data -type d -exec chmod 770 {} \;
find data -type f -exec chmod 660 {} \;
```

