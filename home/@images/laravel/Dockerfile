FROM php:8.0-apache

ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN sed -ri -e "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/sites-available/*.conf

RUN a2enmod rewrite
RUN a2enmod ssl

RUN apt-get update
RUN apt-get install -y zlib1g-dev unzip libzip-dev
RUN docker-php-ext-install zip pdo pdo_mysql

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN apt-get install -my wget gnupg

RUN curl -sL https://deb.nodesource.com/setup_current.x | bash -
RUN apt-get install -y nodejs

RUN npm install -g npm@latest

RUN a2enmod headers

COPY rootCA.pem /usr/local/share/ca-certificates/rootCA.crt
RUN rm -f /usr/local/share/ca-certificates/certificate.crt
RUN update-ca-certificates --fresh

RUN apt-get install -y supervisor

CMD service supervisor status || service supervisor start && apache2-foreground
