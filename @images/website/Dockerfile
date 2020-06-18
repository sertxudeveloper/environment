FROM php:7.3-apache

ENV APACHE_DOCUMENT_ROOT /var/www/html/

RUN sed -ri -e "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/sites-available/*.conf

RUN a2enmod rewrite
RUN a2enmod ssl

ENV APACHE_SSL_CERT /etc/ssl/certs/apache_local.pem
ENV APACHE_SSL_KEY /etc/ssl/private/apache_local.key

RUN sed -ri -e "s!/etc/ssl/certs/ssl-cert-snakeoil.pem!${APACHE_SSL_CERT}!g" /etc/apache2/sites-available/default-ssl.conf
RUN sed -ri -e "s!/etc/ssl/private/ssl-cert-snakeoil.key!${APACHE_SSL_KEY}!g" /etc/apache2/sites-available/default-ssl.conf

RUN a2ensite default-ssl.conf

RUN apt-get update
RUN apt-get install -y zlib1g-dev unzip libzip-dev
RUN docker-php-ext-install zip pdo pdo_mysql

RUN apt-get install -my wget gnupg

RUN a2enmod headers

EXPOSE 80 443
